import Foundation

class TMDBService {
    static let shared = TMDBService()
    private init() {}
    
    // Services
    private let coordinator = ContentSearchCoordinator()
    private let apiClient = TMDBAPIClient.shared
    private let movieService = MovieSearchService()
    private let tvService = TVShowSearchService()
    
    // MARK: - Facade Methods for Backward Compatibility
    
    // MARK: - Mixed Content Methods
    func fetchTrending() async throws -> [TMDBContent] {
        return try await coordinator.fetchTrending()
    }
    
    func search(_ query: String) async throws -> [TMDBContent] {
        return try await coordinator.search(query)
    }
    
    // MARK: - Movie-Specific Methods
    func fetchPopularMovies() async throws -> [TMDBContent] {
        return try await movieService.fetchPopularMovies()
    }
    
    func fetchTopRatedMovies() async throws -> [TMDBContent] {
        return try await movieService.fetchTopRatedMovies()
    }
    
    // MARK: - TV Show-Specific Methods
    func fetchPopularTVShows() async throws -> [TMDBContent] {
        return try await tvService.fetchPopularTVShows()
    }
    
    func fetchTopRatedTVShows() async throws -> [TMDBContent] {
        return try await tvService.fetchTopRatedTVShows()
    }
    
    func fetchAiringToday() async throws -> [TMDBContent] {
        return try await tvService.fetchAiringToday()
    }
    
    func fetchOnTheAir() async throws -> [TMDBContent] {
        return try await tvService.fetchOnTheAir()
    }
    
    func fetchKDramas() async throws -> [TMDBContent] {
        return try await tvService.fetchKDramas()
    }
    
    // MARK: - ✅ FIXED: Enhanced Genre Search with Content Type Support
    func fetchByGenre(_ genreString: String) async throws -> [TMDBContent] {
        // Default to mixed content (existing behavior)
        return try await coordinator.fetchByGenre(genreString, contentType: nil)
    }
    
    // ✅ NEW: Content-type-aware genre search
    func fetchByGenre(_ genreString: String, contentType: ContentType) async throws -> [TMDBContent] {
        return try await coordinator.fetchByGenre(genreString, contentType: contentType)
    }
    
    // ✅ NEW: Year + Genre search with content type support
    func fetchByGenreWithYear(_ genreString: String, yearRange: ClosedRange<Int>) async throws -> [TMDBContent] {
        return try await coordinator.fetchByGenreWithYear(genreString, yearRange: yearRange, contentType: nil)
    }
    
    func fetchByGenreWithYear(_ genreString: String, yearRange: ClosedRange<Int>, contentType: ContentType) async throws -> [TMDBContent] {
        return try await coordinator.fetchByGenreWithYear(genreString, yearRange: yearRange, contentType: contentType)
    }
    
    // MARK: - Actor Search
    func searchActorSimple(_ actorName: String) async throws -> [TMDBContent] {
        return try await coordinator.searchActorSimple(actorName, contentType: nil)
    }
    
    func searchActorSimple(_ actorName: String, contentType: ContentType) async throws -> [TMDBContent] {
        return try await coordinator.searchActorSimple(actorName, contentType: contentType)
    }
    
    // MARK: - Legacy Content Methods (delegate to API client)
    func fetchContent(from endpoint: TMDBEndpoint) async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: endpoint)
    }
    
    // MARK: - Individual Content Details
    func fetchMovieDetails(movieId: Int) async throws -> MovieDetailsResponse {
        let url = "\(apiClient.baseAPIURL)/movie/\(movieId)?api_key=\(apiClient.tmdbAPIKey)&append_to_response=credits,videos"
        return try await apiClient.fetchSingleContent(url, as: MovieDetailsResponse.self)
    }
    
    func fetchTVShowDetails(tvShowId: Int) async throws -> TVShowDetailsResponse {
        let url = "\(apiClient.baseAPIURL)/tv/\(tvShowId)?api_key=\(apiClient.tmdbAPIKey)&append_to_response=credits,videos"
        return try await apiClient.fetchSingleContent(url, as: TVShowDetailsResponse.self)
    }
    
    func fetchContentById(_ id: Int, type: String) async throws -> TMDBContent {
        if type == "movie_watchlist" {
            return try await fetchMovieById(id)
        } else {
            return try await fetchTVShowById(id)
        }
    }
    
    private func fetchMovieById(_ id: Int) async throws -> TMDBContent {
        let urlString = "\(apiClient.baseAPIURL)/movie/\(id)?api_key=\(apiClient.tmdbAPIKey)"
        let movieData = try await apiClient.fetchSingleContent(urlString, as: MovieSingleResponse.self)
        return movieData.toTMDBContent()
    }
    
    private func fetchTVShowById(_ id: Int) async throws -> TMDBContent {
        let urlString = "\(apiClient.baseAPIURL)/tv/\(id)?api_key=\(apiClient.tmdbAPIKey)"
        let tvData = try await apiClient.fetchSingleContent(urlString, as: TVShowSingleResponse.self)
        return tvData.toTMDBContent()
    }
    
    // MARK: - Watch Providers
    func fetchWatchProviders(for contentId: Int, contentType: TMDBContentType) async throws -> WatchProviders? {
        let typeString = contentType == .movie ? "movie" : "tv"
        let urlString = "\(apiClient.baseAPIURL)/\(typeString)/\(contentId)/watch/providers?api_key=\(apiClient.tmdbAPIKey)"
        
        let watchResponse = try await apiClient.fetchSingleContent(urlString, as: WatchProvidersResponse.self)
        return watchResponse.results?["US"]
    }
    
    // MARK: - Similar/Recommended Content
    func fetchSimilarContent(for contentId: Int, contentType: TMDBContentType) async throws -> [TMDBContent] {
        let typeString = contentType == .movie ? "movie" : "tv"
        let url = "\(apiClient.baseAPIURL)/\(typeString)/\(contentId)/similar?api_key=\(apiClient.tmdbAPIKey)"
        return try await apiClient.fetchURL(url)
    }
    
    // MARK: - Search with Content Type
    func searchContent(query: String, contentType: SearchContentType? = nil) async throws -> [TMDBContent] {
        let endpoint: String
        
        switch contentType {
        case .movie:
            endpoint = "search/movie"
        case .tv:
            endpoint = "search/tv"
        case .none:
            endpoint = "search/multi"
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = "\(apiClient.baseAPIURL)/\(endpoint)?api_key=\(apiClient.tmdbAPIKey)&query=\(encodedQuery)"
        
        return try await apiClient.fetchURL(url)
    }
}

// MARK: - Supporting Enums
enum SearchContentType {
    case movie
    case tv
}
