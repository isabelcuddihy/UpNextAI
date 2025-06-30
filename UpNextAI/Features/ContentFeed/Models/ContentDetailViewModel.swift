//
//  ContentDetailViewModel.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/21/25.
//

import Foundation
import Combine

// MARK: - Content Detail ViewModel
@MainActor
class ContentDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var contentDetails: ContentDetails?
    @Published var cast: [CastMember] = []
    @Published var crew: [CrewMember] = []
    @Published var similarContent: [TMDBService.TMDBContent] = []
    @Published var videos: [VideoContent] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // User interaction states
    @Published var isLiked = false
    @Published var isDisliked = false
    @Published var isInWatchlist = false
    
    // MARK: - Private Properties
    private let tmdbService = TMDBService.shared
    private var currentUserProfile: UserProfileCoreData?
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        
    }
    
    // MARK: - Computed Properties
    var hasCredits: Bool {
        !cast.isEmpty || !crew.isEmpty
    }
    
    var hasSimilarContent: Bool {
        !similarContent.isEmpty
    }
    
    var hasVideos: Bool {
        !videos.isEmpty
    }
    
    // MARK: - Public Methods
    
    @Published var watchProviders: WatchProviders?

    func loadDetails(for content: TMDBService.TMDBContent) async {
        isLoading = true
        errorMessage = nil
        
        // Remove do-catch - these functions handle their own errors
        if content.isMovie {
            await loadMovieDetails(movieId: content.id)
        } else if content.isTVShow {
            await loadTVShowDetails(tvShowId: content.id)
        }
        
        await loadSimilarContent(for: content)
        await loadWatchProviders(for: content)
        loadUserPreferences(for: content)
        
        isLoading = false
    }

    // ADD THIS METHOD if you don't have it
    private func loadWatchProviders(for content: TMDBService.TMDBContent) async {
        do {
            let contentType = getContentType(for: content)
            watchProviders = try await tmdbService.fetchWatchProviders(for: content.id, contentType: contentType)
            print("✅ Loaded watch providers: \(watchProviders?.flatrate?.count ?? 0) subscription, \(watchProviders?.rent?.count ?? 0) rental")
        } catch {
            print("⚠️ Failed to load watch providers: \(error)")
            // Don't throw - streaming data is nice to have but not critical
            watchProviders = nil
        }
    }
    
    // MARK: - User Interaction Methods
    
    
    func clearError() {
        errorMessage = nil
    }

    func loadWatchlistStatus(for content: TMDBService.TMDBContent, userRepository: UserPreferenceRepository) async {
        do {
            // Get current user profile
            guard let profile = try await userRepository.getUserProfile() else { return }
            
            // Check for watchlist preference
            let watchlistType = content.isMovie ? "movie_watchlist" : "tv_watchlist"
            let preferences = try await userRepository.getPreferences(for: profile, type: watchlistType)
            
            // Check if this specific content is in watchlist
            let isInWatchlist = preferences.contains { $0.tmdbId == content.id && $0.isLiked }
            
            await MainActor.run {
                self.isInWatchlist = isInWatchlist
            }
        } catch {
            print("⚠️ Failed to load watchlist status: \(error)")
        }
    }

    func toggleWatchlist(_ content: TMDBService.TMDBContent, userRepository: UserPreferenceRepository, tabService: TabCommunicationService) async {
        do {
            guard let profile = try await userRepository.getUserProfile() else { return }
            
            let watchlistType = content.isMovie ? "movie_watchlist" : "tv_watchlist"
            
            if isInWatchlist {
                // Remove from watchlist - DELETE the record
                let preferences = try await userRepository.getPreferences(for: profile, type: watchlistType)
                if let existingPref = preferences.first(where: { $0.tmdbId == content.id }) {
                    try await userRepository.deletePreference(existingPref)
                    print("🗑️ Deleted from watchlist: \(content.displayTitle)")
                }
            } else {
                // Add to watchlist - CREATE new record
                try await userRepository.addPreference(
                    to: profile,
                    type: watchlistType,
                    name: content.displayTitle,
                    tmdbId: Int64(content.id),
                    isLiked: true
                )
                print("📚 Added to watchlist: \(content.displayTitle)")
            }
            
            await MainActor.run {
                self.isInWatchlist.toggle()
            }
            
        } catch {
            print("❌ Failed to toggle watchlist: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    // Helper method to convert content to the right ContentType for TMDBService
    private func getContentType(for content: TMDBService.TMDBContent) -> TMDBContentType {
        return content.isMovie ? .movie : .tvShow
    }
    
    
    private func loadMovieDetails(movieId: Int) async {
        do {
            let movieDetails = try await tmdbService.fetchMovieDetails(movieId: movieId)
            
            // Convert to our unified ContentDetails model
            contentDetails = ContentDetails(
                id: movieDetails.id,
                title: movieDetails.title,
                overview: movieDetails.overview,
                runtime: movieDetails.runtime,
                numberOfSeasons: nil,
                numberOfEpisodes: nil,
                status: movieDetails.status,
                genres: movieDetails.genres?.map { $0.name } ?? [],
                spokenLanguages: movieDetails.spokenLanguages?.map { $0.name },
                productionCompanies: movieDetails.productionCompanies?.map { $0.name } ?? []
            )
            
            // Extract cast and crew
            if let credits = movieDetails.credits {
                cast = credits.cast?.map { CastMember(from: $0) } ?? []
                crew = credits.crew?.map { CrewMember(from: $0) } ?? []
            }
            
            // Extract videos
            if let videoResults = movieDetails.videos?.results {
                videos = videoResults.map { VideoContent(from: $0) }
            }
            
        } catch {
            handleError(error)
        }
    }
    
    private func loadTVShowDetails(tvShowId: Int) async {
        do {
            let tvDetails = try await tmdbService.fetchTVShowDetails(tvShowId: tvShowId)
            
            // Convert to our unified ContentDetails model
            contentDetails = ContentDetails(
                id: tvDetails.id,
                title: tvDetails.name,
                overview: tvDetails.overview,
                runtime: tvDetails.episodeRunTime?.first,
                numberOfSeasons: tvDetails.numberOfSeasons,
                numberOfEpisodes: tvDetails.numberOfEpisodes,
                status: tvDetails.status,
                genres: tvDetails.genres?.map { $0.name } ?? [],
                spokenLanguages: tvDetails.spokenLanguages?.map { $0.name },
                productionCompanies: tvDetails.productionCompanies?.map { $0.name } ?? []
            )
            
            // Extract cast and crew
            if let credits = tvDetails.credits {
                cast = credits.cast?.map { CastMember(from: $0) } ?? []
                crew = credits.crew?.map { CrewMember(from: $0) } ?? []
            }
            
            // Extract videos
            if let videoResults = tvDetails.videos?.results {
                videos = videoResults.map { VideoContent(from: $0) }
            }
            
        } catch {
            handleError(error)
        }
    }
    
    // Updated loadSimilarContent method using the helper
    private func loadSimilarContent(for content: TMDBService.TMDBContent) async {
        do {
            let contentType = getContentType(for: content)
            similarContent = try await tmdbService.fetchSimilarContent(
                for: content.id,
                contentType: contentType
            )
        } catch {
            print("⚠️ Failed to load similar content: \(error)")
            // Don't throw error for similar content - it's not critical
        }
    }
    
    private func loadUserPreferences(for content: TMDBService.TMDBContent) {
        // TODO: Load from Core Data
        // For now, simulate some preferences
        isLiked = false
        isDisliked = false
        isInWatchlist = false
    }
    
    private func saveUserInteraction(content: TMDBService.TMDBContent, interactionType: UserInteractionType) {
        // TODO: Implement Core Data saving
        print("💾 Saving interaction: \(interactionType.rawValue) for \(content.displayTitle)")
        
        // TODO: Send to ML backend for learning
        let contentType: UserContentType = content.isMovie ? .movie : .tvShow
        _ = UserInteraction(
            tmdbId: content.id,
            contentType: contentType,
            interactionType: interactionType,
            timestamp: Date(),
            genres: content.genreIds?.map { String($0) } ?? []
        )
        
        // This is where you'd send to your backend ML service
        // sendInteractionToMLService(interaction)
    }
    
    private func removeUserInteraction(content: TMDBService.TMDBContent, interactionType: UserInteractionType) {
        // TODO: Implement Core Data removal
        print("🗑️ Removing interaction: \(interactionType.rawValue) for \(content.displayTitle)")
    }
    
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
        print("❌ Error loading content details: \(error)")
    }
}

// MARK: - Supporting Models

struct ContentDetails {
    let id: Int
    let title: String
    let overview: String?
    let runtime: Int? // Minutes for movies, episode runtime for TV
    let numberOfSeasons: Int? // TV shows only
    let numberOfEpisodes: Int? // TV shows only
    let status: String?
    let genres: [String]
    let spokenLanguages: [String]?
    let productionCompanies: [String]
}

struct CastMember {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    
    var profileURL: String {
        guard let profilePath = profilePath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(profilePath)"
    }
    
    init(from tmdbCast: TMDBCastMember) {
        self.id = tmdbCast.id
        self.name = tmdbCast.name
        self.character = tmdbCast.character ?? "Unknown"
        self.profilePath = tmdbCast.profilePath
    }
}

struct CrewMember {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
    
    var profileURL: String {
        guard let profilePath = profilePath else { return "" }
        return "https://image.tmdb.org/t/p/w500\(profilePath)"
    }
    
    init(from tmdbCrew: TMDBCrewMember) {
        self.id = tmdbCrew.id
        self.name = tmdbCrew.name
        self.job = tmdbCrew.job ?? "Unknown"
        self.department = tmdbCrew.department ?? "Unknown"
        self.profilePath = tmdbCrew.profilePath
    }
}

struct VideoContent {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    
    var youtubeURL: String {
        guard site.lowercased() == "youtube" else { return "" }
        return "https://www.youtube.com/watch?v=\(key)"
    }
    
    var isTrailer: Bool {
        type.lowercased() == "trailer"
    }
    
    init(from tmdbVideo: TMDBVideo) {
        self.id = tmdbVideo.id
        self.key = tmdbVideo.key
        self.name = tmdbVideo.name
        self.site = tmdbVideo.site
        self.type = tmdbVideo.type
    }
}

// MARK: - User Interaction Types

enum UserInteractionType: String, CaseIterable {
    case liked = "liked"
    case disliked = "disliked"
    case addedToWatchlist = "added_to_watchlist"
    case viewed = "viewed"
    case shared = "shared"
}

enum UserContentType: String, CaseIterable {
    case movie = "movie"
    case tvShow = "tv"
}

struct UserInteraction {
    let tmdbId: Int
    let contentType: UserContentType
    let interactionType: UserInteractionType
    let timestamp: Date
    let genres: [String]
}
