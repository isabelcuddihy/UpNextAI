//
//  ContentViewModel.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//
import Foundation
import Combine

// MARK: - Content ViewModel
@MainActor
class ContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var contentSections: [ContentSection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let tmdbService = TMDBService.shared
    private let userRepository: UserPreferenceRepository
    private let tabCommunicationService: TabCommunicationService
    
    private var cancellables = Set<AnyCancellable>()
    private var currentUserProfile: UserProfileCoreData?
    private var currentLoadTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    var hasContent: Bool {
        !contentSections.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoading && contentSections.isEmpty && errorMessage == nil
    }
    
    // MARK: - Initialization - IMPROVED
    init(userRepository: UserPreferenceRepository, tabCommunicationService: TabCommunicationService) {
        self.userRepository = userRepository
        self.tabCommunicationService = tabCommunicationService
        
        // FIXED: Load user profile synchronously at init
        Task {
            print("🎬 ContentViewModel initializing...")
            await loadCurrentUserProfile()
            print("🎬 ContentViewModel ready")
        }
        
        setupCommunication()
    }
    
    // MARK: - Public Methods
    
    // IMPROVED: More robust loading with better error handling
    func loadMainFeed() async {
        // Prevent multiple simultaneous loads
        guard !isLoading else {
            print("⚠️ Already loading, skipping duplicate request")
            return
        }
        
        print("🚀 Starting main feed load...")
        
        // Cancel any existing load task
        currentLoadTask?.cancel()
        
        // Create new load task
        currentLoadTask = Task {
            await performMainFeedLoad()
        }
        
        await currentLoadTask?.value
    }
    
    private func performMainFeedLoad() async {
        // ENSURE we're on main thread
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // ENSURE user profile is loaded first with timeout
        if currentUserProfile == nil {
            print("⏳ User profile not loaded, loading now...")
            await loadCurrentUserProfile()
            
            // Give it a moment to process
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            if currentUserProfile == nil {
                print("❌ Failed to load user profile after timeout")
                await MainActor.run {
                    errorMessage = "Failed to load user profile"
                    isLoading = false
                }
                return
            }
        }
        
        var newSections: [ContentSection] = []
        
        // 1. Recommended for You (most important)
        print("🎯 Loading personalized recommendations...")
        let recommendedContent = await loadRecommendedForUser()
        print("🎯 Got \(recommendedContent.count) recommended items")
        
        if !recommendedContent.isEmpty {
            newSections.append(ContentSection(
                title: "Recommended for You",
                content: recommendedContent,
                category: .recommended
            ))
            print("✅ Added 'Recommended for You' section")
        }
        
        // Early exit check
        if Task.isCancelled {
            await MainActor.run { isLoading = false }
            return
        }
        
        // 2. Load other sections in parallel to speed things up
        async let watchlistTask = loadUserWatchlist()
        async let genreSectionsTask = loadGenreSectionsAsync()
        async let streamingTask = loadStreamingContentAsync()
        
        // Wait for all to complete
        let (watchlistContent, genreSections, streamingSections) = await (watchlistTask, genreSectionsTask, streamingTask)
        
        // Add watchlist if not empty
        if !watchlistContent.isEmpty {
            newSections.append(ContentSection(
                title: "Your Watchlist",
                content: watchlistContent,
                category: .watchlist
            ))
        }
        
        // Add genre sections
        newSections.append(contentsOf: genreSections)
        
        // Add streaming sections
        newSections.append(contentsOf: streamingSections)
        
        // Final update on main thread
        await MainActor.run {
            if !Task.isCancelled {
                contentSections = newSections
                print("✅ Loaded \(contentSections.count) content sections")
            }
            isLoading = false
        }
    }
    
    // IMPROVED: Better refresh logic
    func refresh() async {
        print("🔄 Starting refresh...")
        
        // Cancel any existing tasks
        currentLoadTask?.cancel()
        
        // Brief pause to ensure cancellation
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Clear content and reload everything
        await MainActor.run {
            contentSections.removeAll()
        }
        
        // Force reload user profile
        await loadCurrentUserProfile()
        
        // Load fresh content
        await loadMainFeed()
        
        print("✅ Refresh completed")
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    private func setupCommunication() {
        // Listen for watchlist updates from other tabs
        tabCommunicationService.$watchlistUpdated
            .sink { [weak self] _ in
                Task {
                    await self?.refresh()
                }
            }
            .store(in: &cancellables)
        
        // Listen for genre updates from Profile tab
        tabCommunicationService.$genresUpdated
            .sink { [weak self] _ in
                Task {
                    print("📢 Received genre update notification, refreshing recommendations...")
                    // Just refresh the whole feed to avoid conflicts
                    await self?.refresh()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Personalized Content Methods

    private func loadCurrentUserProfile() async {
        do {
            currentUserProfile = try await userRepository.getUserProfile()
            print("👤 Loaded user profile: \(currentUserProfile?.name ?? "No profile")")
            
            if let profile = currentUserProfile {
                debugUserPreferences(from: profile)
            }
        } catch {
            print("⚠️ Failed to load user profile: \(error)")
        }
    }
    
    private func debugUserPreferences(from profile: UserProfileCoreData) {
        Task {
            do {
                let preferences = try await userRepository.getPreferences(for: profile)
                print("📊 Found \(preferences.count) user preferences:")
                
                for (index, preference) in preferences.enumerated() {
                    print("  Preference \(index + 1):")
                    print("    Type: \(preference.type ?? "nil")")
                    print("    Name: \(preference.name ?? "nil")")
                    print("    Is Liked: \(preference.isLiked)")
                    print("    TMDB ID: \(preference.tmdbId)")
                    print("    ---")
                }
            } catch {
                print("❌ Debug failed: \(error)")
            }
        }
    }
    
    private func loadRecommendedForUser() async -> [TMDBService.TMDBContent] {
        print("🚀 loadRecommendedForUser() called")
        
        guard let userProfile = currentUserProfile else {
            print("❌ No user profile found, using fallback")
            return await loadFallbackRecommendations()
        }
        
        let favoriteGenres = await getUserFavoriteGenres(from: userProfile)
        print("🎯 User's favorite genres for recommendations: \(favoriteGenres)")
        
        if favoriteGenres.isEmpty {
            print("⚠️ No genres found, using fallback recommendations")
            return await loadFallbackRecommendations()
        }
        
        var recommendations: [TMDBService.TMDBContent] = []
        var seenMovieIds: Set<Int> = []
        
        for genre in favoriteGenres.prefix(4) {
            print("🔍 Fetching content for genre: \(genre)")
            do {
                let genreContent = try await tmdbService.fetchByGenre(genre)
                print("📊 Found \(genreContent.count) items for \(genre)")
                
                let topRated = genreContent
                    .filter { $0.voteAverage ?? 5.1 > 7.0 }
                    .filter { !seenMovieIds.contains($0.id) }
                    .prefix(10)
                
                print("⭐ Filtered to \(topRated.count) unique high-rated \(genre) items")
                
                for movie in topRated {
                    seenMovieIds.insert(movie.id)
                }
                
                recommendations.append(contentsOf: topRated)
            } catch {
                print("❌ Failed to load genre \(genre): \(error)")
            }
        }
        
        let finalRecommendations = Array(recommendations.shuffled().prefix(25))
        print("🎬 Final recommendations: \(finalRecommendations.count) unique items")
        
        return finalRecommendations
    }
    
    private func loadUserWatchlist() async -> [TMDBService.TMDBContent] {
        guard let userProfile = currentUserProfile else { return [] }
        
        do {
            let movieWatchlist = try await userRepository.getPreferences(for: userProfile, type: "movie_watchlist")
            let tvWatchlist = try await userRepository.getPreferences(for: userProfile, type: "tv_watchlist")
            
            var watchlistContent: [TMDBService.TMDBContent] = []
            
            // Fetch fresh TMDB data for each item
            for preference in movieWatchlist + tvWatchlist {
                if let freshContent = await fetchWatchlistItem(preference) {
                    watchlistContent.append(freshContent)
                }
            }
            
            return Array(watchlistContent.prefix(25))
        } catch {
            print("⚠️ Failed to load watchlist: \(error)")
            return []
        }
    }

    private func fetchWatchlistItem(_ preference: UserPreferenceCoreData) async -> TMDBService.TMDBContent? {
        do {
            return try await tmdbService.fetchContentById(Int(preference.tmdbId), type: preference.type ?? "")
        } catch {
            print("⚠️ Failed to fetch ID \(preference.tmdbId): \(error)")
            return nil
        }
    }
    
    // IMPROVED: Load genre sections in parallel
    private func loadGenreSectionsAsync() async -> [ContentSection] {
        guard let userProfile = currentUserProfile else { return [] }
        
        let favoriteGenres = await getUserFavoriteGenres(from: userProfile)
        var sections: [ContentSection] = []
        
        // Load first 3 genres in parallel for speed
        let genresToLoad = Array(favoriteGenres.prefix(3))
        
        await withTaskGroup(of: ContentSection?.self) { group in
            for genre in genresToLoad {
                group.addTask {
                    do {
                        let genreContent = try await self.tmdbService.fetchByGenre(genre)
                        let filteredContent = genreContent
                            .filter { $0.voteAverage ?? 5.1 > 6.0 } // Higher quality threshold
                            .prefix(15)
                        
                        print("📊 \(genre): TMDB returned \(genreContent.count), after filter: \(filteredContent.count)")
                        
                        if !filteredContent.isEmpty {
                            return ContentSection(
                                title: "More \(genre.capitalized)",
                                content: Array(filteredContent),
                                category: .genreBased(genre)
                            )
                        }
                    } catch {
                        print("⚠️ Failed to load \(genre): \(error)")
                    }
                    return nil
                }
            }
            
            for await section in group {
                if let section = section {
                    sections.append(section)
                }
            }
        }
        
        return sections
    }
    
    // IMPROVED: Load streaming content async
    private func loadStreamingContentAsync() async -> [ContentSection] {
        var sections: [ContentSection] = []
        
        do {
            async let topMoviesTask = tmdbService.fetchTopRatedMovies()
            async let topTVTask = tmdbService.fetchTopRatedTVShows()
            
            let (topRatedMovies, topRatedTV) = try await (topMoviesTask, topTVTask)
            
            let qualityMovies = topRatedMovies
                .filter { $0.voteAverage ?? 5.1 > 7.5 }
                .prefix(15)
            
            if !qualityMovies.isEmpty {
                sections.append(ContentSection(
                    title: "Critically Acclaimed Movies",
                    content: Array(qualityMovies),
                    category: .movieTopRated
                ))
            }
            
            let qualityTV = topRatedTV
                .filter { $0.voteAverage ?? 5.1 > 7.5 }
                .prefix(15)
            
            if !qualityTV.isEmpty {
                sections.append(ContentSection(
                    title: "Must-Watch TV Shows",
                    content: Array(qualityTV),
                    category: .tvTopRated
                ))
            }
            
        } catch {
            print("⚠️ Failed to load streaming content: \(error)")
        }
        
        return sections
    }
    
    // LEGACY: Keep for backward compatibility - now calls new async methods
    private func loadPersonalizedGenreSections(_ sections: inout [ContentSection]) async {
        let newSections = await loadGenreSectionsAsync()
        sections.append(contentsOf: newSections)
    }
    
    private func loadStreamingAvailableContent(_ sections: inout [ContentSection]) async {
        let newSections = await loadStreamingContentAsync()
        sections.append(contentsOf: newSections)
    }
    
    private func loadFallbackRecommendations() async -> [TMDBService.TMDBContent] {
        do {
            let topRated = try await tmdbService.fetchTopRatedMovies()
            return Array(topRated.filter { $0.voteAverage ?? 5.1 > 8.0 }.prefix(20))
        } catch {
            print("⚠️ Failed to load fallback recommendations: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func getUserFavoriteGenres(from profile: UserProfileCoreData) async -> [String] {
        do {
            let preferences = try await userRepository.getPreferences(for: profile, type: "genre")
            
            var genres = preferences
                .filter { $0.isLiked }
                .compactMap { $0.name }
                .filter { !$0.isEmpty }
            
            // FIX: Map "True Crime" to "Crime" for better TMDB results
            genres = genres.map { genre in
                if genre.lowercased() == "true crime" {
                    return "Crime"
                }
                return genre
            }
        
            let shuffledGenres = genres.shuffled()
            print("🔀 Shuffled user's genres: \(shuffledGenres)")
            return Array(shuffledGenres.prefix(7))
            
        } catch {
            print("⚠️ Failed to get genre preferences: \(error)")
            return ["Action", "Comedy", "Drama"]
        }
    }
    
    // MARK: - Private Error Handling
    
    private func handleError(_ error: Error) {
        let message: String
        
        if let tmdbError = error as? TMDBError {
            switch tmdbError {
            case .invalidURL:
                message = "Invalid request. Please try again."
            case .invalidResponse:
                message = "Server error. Please try again later."
            case .decodingError:
                message = "Data parsing error. Please try again."
            }
        } else {
            message = "Something went wrong: \(error.localizedDescription)"
        }
        
        errorMessage = message
        print("❌ Error loading content: \(error)")
    }
}

// MARK: - Content Interaction Methods
extension ContentViewModel {

    /// Add content to watchlist
    func addToWatchlist(_ content: TMDBService.TMDBContent) {
        print("📚 Added to watchlist: \(content.displayTitle)")
        Task {
            await refresh()
        }
    }
    
    /// Handle content tap - navigate to detail view
    func handleMovieTap(_ content: TMDBService.TMDBContent) {
        print("🎬 Tapped: \(content.displayTitle)")
        // TODO: Track user engagement for ML
    }
}
