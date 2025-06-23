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
    private let userRepository = UserPreferenceRepository() // Add this
    private var cancellables = Set<AnyCancellable>()
    private var currentUserProfile: UserProfileCoreData?
    
    // MARK: - Computed Properties
    var hasContent: Bool {
        !contentSections.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoading && contentSections.isEmpty && errorMessage == nil
    }
    
    // MARK: - Initialization
    init() {
        Task {
            await loadCurrentUserProfile()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load personalized content feed based on user preferences
    func loadMainFeed() async {
        isLoading = true
        errorMessage = nil
        
        // ENSURE user profile is loaded first
        if currentUserProfile == nil {
            print("⏳ Waiting for user profile to load...")
            await loadCurrentUserProfile()
        }
        
        do {
            var newSections: [ContentSection] = []
            
            // 1. Recommended for You (top priority)
            let recommendedContent = await loadRecommendedForUser()
            print("🎯 Got \(recommendedContent.count) recommended items")
            if !recommendedContent.isEmpty {
                newSections.append(ContentSection(
                    title: "Recommended for You",
                    content: recommendedContent,
                    category: .recommended
                ))
                print("✅ Added 'Recommended for You' section")
            } else {
                print("⚠️ No recommended content, skipping section")
            }
            
            // 2. Your Watchlist (if not empty)
            let watchlistContent = await loadUserWatchlist()
            if !watchlistContent.isEmpty {
                newSections.append(ContentSection(
                    title: "Your Watchlist",
                    content: watchlistContent,
                    category: .watchlist
                ))
            }
            
            // 3. Genre-based sections from user preferences
            await loadPersonalizedGenreSections(&newSections)
            
            // 4. High-quality streaming content
            await loadStreamingAvailableContent(&newSections)
            
            contentSections = newSections
            print("✅ Loaded \(contentSections.count) personalized content sections")
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Refresh current content
    func refresh() async {
        await loadCurrentUserProfile()
        await loadMainFeed()
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }

    
    // MARK: - Personalized Content Methods

    private func loadCurrentUserProfile() async {
        do {
            currentUserProfile = try await userRepository.getUserProfile()
            print("👤 Loaded user profile: \(currentUserProfile?.name ?? "No profile")")
            
            // Add this debug line
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
        var seenMovieIds: Set<Int> = [] // Track seen movie IDs
        
        for genre in favoriteGenres.prefix(2) {
            print("🔍 Fetching content for genre: \(genre)")
            do {
                let genreContent = try await tmdbService.fetchByGenre(genre)
                print("📊 Found \(genreContent.count) items for \(genre)")
                
                let topRated = genreContent
                    .filter { $0.voteAverage > 7.0 }
                    .filter { !seenMovieIds.contains($0.id) } // Remove duplicates
                    .prefix(5)
                
                print("⭐ Filtered to \(topRated.count) unique high-rated \(genre) items")
                
                // Add IDs to seen set
                for movie in topRated {
                    seenMovieIds.insert(movie.id)
                }
                
                recommendations.append(contentsOf: topRated)
            } catch {
                print("❌ Failed to load genre \(genre): \(error)")
            }
        }
        
        let finalRecommendations = Array(recommendations.shuffled().prefix(15))
        print("🎬 Final recommendations: \(finalRecommendations.count) unique items")
        
        return finalRecommendations
    }
    
    private func loadUserWatchlist() async -> [TMDBService.TMDBContent] {
        // TODO: Load from Core Data watchlist when implemented
        // For now, return empty - watchlist will be populated as users add items
        return []
    }
    
    private func loadPersonalizedGenreSections(_ sections: inout [ContentSection]) async {
        guard let userProfile = currentUserProfile else { return }
        
        let favoriteGenres = await getUserFavoriteGenres(from: userProfile)
        
        for genre in favoriteGenres.prefix(3) { // Show top 3 genre preferences
            do {
                let genreContent = try await tmdbService.fetchByGenre(genre)
                let filteredContent = genreContent
                    .filter { $0.voteAverage > 6.5 } // Good quality threshold
                    .prefix(12)
                
                if !filteredContent.isEmpty {
                    sections.append(ContentSection(
                        title: "More \(genre.capitalized)",
                        content: Array(filteredContent),
                        category: .genreBased(genre)
                    ))
                }
            } catch {
                print("⚠️ Failed to load personalized \(genre): \(error)")
            }
        }
    }
    
    private func loadStreamingAvailableContent(_ sections: inout [ContentSection]) async {
        do {
            // Load top-rated movies (better streaming availability than "popular")
            let topRatedMovies = try await tmdbService.fetchTopRatedMovies()
            let qualityMovies = topRatedMovies
                .filter { $0.voteAverage > 7.5 } // High quality only
                .prefix(12)
            
            if !qualityMovies.isEmpty {
                sections.append(ContentSection(
                    title: "Critically Acclaimed Movies",
                    content: Array(qualityMovies),
                    category: .movieTopRated
                ))
            }
            
            // Add top-rated TV shows
            let topRatedTV = try await tmdbService.fetchTopRatedTVShows()
            let qualityTV = topRatedTV
                .filter { $0.voteAverage > 7.5 }
                .prefix(12)
            
            if !qualityTV.isEmpty {
                sections.append(ContentSection(
                    title: "Must-Watch TV Shows",
                    content: Array(qualityTV),
                    category: .tvTopRated
                ))
            }
            
        } catch {
            print("⚠️ Failed to load high-quality content: \(error)")
        }
    }
    
    private func loadFallbackRecommendations() async -> [TMDBService.TMDBContent] {
        // Fallback for new users or if preferences aren't available
        do {
            let topRated = try await tmdbService.fetchTopRatedMovies()
            return Array(topRated.filter { $0.voteAverage > 8.0 }.prefix(10))
        } catch {
            print("⚠️ Failed to load fallback recommendations: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func getUserFavoriteGenres(from profile: UserProfileCoreData) async -> [String] {
        do {
            // Use repository method instead of direct Core Data relationship access
            let preferences = try await userRepository.getPreferences(for: profile, type: "genre")
            
            let genres = preferences
                .filter { $0.isLiked } // Only get liked genres
                .compactMap { $0.name }
                .filter { !$0.isEmpty }
            
            print("🎯 Found user's selected genres: \(genres)")
            return Array(genres.prefix(5)) // Limit to top 5 genres
            
        } catch {
            print("⚠️ Failed to get genre preferences: \(error)")
            return ["Action", "Comedy", "Drama"] // Fallback
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
    /// Handle user liking content (ML learning data)
    func likeContent(_ content: TMDBService.TMDBContent) {
        print("❤️ Liked: \(content.displayTitle)")
        // TODO: Save to Core Data preferences
        // TODO: Update AI learning model
        // This will be key data for your ML chatbot!
    }
    
    /// Handle user disliking content (ML learning data)
    func dislikeContent(_ content: TMDBService.TMDBContent) {
        print("👎 Disliked: \(content.displayTitle)")
        // TODO: Save to Core Data preferences
        // TODO: Update AI learning model
        // This helps the chatbot learn what NOT to recommend
    }
    
    /// Add content to watchlist
    func addToWatchlist(_ content: TMDBService.TMDBContent) {
        print("📚 Added to watchlist: \(content.displayTitle)")
        // TODO: Implement watchlist Core Data storage
        // TODO: Refresh watchlist section
        Task {
            await refresh() // Refresh to show updated watchlist
        }
    }
    
    /// Handle content tap - navigate to detail view
    func handleMovieTap(_ content: TMDBService.TMDBContent) {
        print("🎬 Tapped: \(content.displayTitle)")
        // TODO: Track user engagement for ML
        // This interaction data helps improve recommendations
    }
}
