import Foundation

class TMDBService {
    static let shared = TMDBService()
    private init() {}
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    private var apiKey: String {
        return "253293fd6119b5f47cd8bc1307581789"
    }
    
    private var accessToken: String {
        return "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNTMyOTNmZDYxMTliNWY0N2NkOGJjMTMwNzU4MTc4OSIsIm5iZiI6MTcyNTI5OTcyNC40MDg1OTksInN1YiI6IjY2ZDQ5NDViZDk0ZGZmZDhmNzAxZjAwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wm2CLu4jgu5Y-CGNe7XjGWny847vKkExQ0s0J_9jQBY"
    }
    
    // MARK: - API Endpoints
    enum Endpoint {
        // Mixed content
        case trending
        case search(query: String)
        
        // Movie-specific endpoints
        case moviePopular
        case movieTopRated
        case actionMovies
        case comedyMovies
        case horrorMovies
        case romanceMovies
        case documentaries
        case fantasyMovies
        case animationMovies
        
        // TV-specific endpoints
        case tvPopular
        case tvTopRated
        case tvAiringToday
        case tvOnTheAir
        case actionTVShows
        case comedyTVShows
        case dramaTVShows
        case crimeTV
        case kdramas
        
        func path(with apiKey: String) -> String {
            switch self {
                // Mixed content
            case .trending:
                return "/trending/all/week?api_key=\(apiKey)&language=en-US"
            case .search(let query):
                return "/search/multi?api_key=\(apiKey)&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                
                // Movie endpoints
            case .moviePopular:
                return "/movie/popular?api_key=\(apiKey)&language=en-US"
            case .movieTopRated:
                return "/movie/top_rated?api_key=\(apiKey)&language=en-US"
            case .actionMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=28"
            case .comedyMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=35"
            case .horrorMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=27"
            case .romanceMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=10749"
            case .documentaries:
                return "/discover/movie?api_key=\(apiKey)&with_genres=99"
                
            case .fantasyMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=14"  // Fantasy genre ID
            case .animationMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=16"  // Animation genre ID
                
                // TV endpoints
            case .tvPopular:
                return "/tv/popular?api_key=\(apiKey)&language=en-US"
            case .tvTopRated:
                return "/tv/top_rated?api_key=\(apiKey)&language=en-US"
            case .tvAiringToday:
                return "/tv/airing_today?api_key=\(apiKey)&language=en-US"
            case .tvOnTheAir:
                return "/tv/on_the_air?api_key=\(apiKey)&language=en-US"
            case .actionTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=10759" // Action & Adventure
            case .comedyTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=35"
            case .dramaTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=18"
            case .crimeTV:
                return "/discover/tv?api_key=\(apiKey)&with_genres=80"
            case .kdramas:
                return "/discover/tv?api_key=\(apiKey)&with_genres=18&with_origin_country=KR" // Korean dramas
            }
        }
    }
    
    // MARK: - Response Models
    struct TMDBResponse: Codable {
        let results: [TMDBContent]
    }
    
    struct TMDBContent: Codable {
        let id: Int
        let title: String?
        let name: String? // For TV shows
        let overview: String?
        let posterPath: String?
        let backdropPath: String?
        let releaseDate: String?
        let firstAirDate: String? // For TV shows
        let voteAverage: Double
        let genreIds: [Int]
        let mediaType: String?
        
        enum CodingKeys: String, CodingKey {
            case id, title, name, overview
            case posterPath = "poster_path"
            case backdropPath = "backdrop_path"
            case releaseDate = "release_date"
            case firstAirDate = "first_air_date"
            case voteAverage = "vote_average"
            case genreIds = "genre_ids"
            case mediaType = "media_type"
        }
        
        // Helper computed properties
        var displayTitle: String {
            return title ?? name ?? "Unknown Title"
        }
        
        var displayDate: String {
            return releaseDate ?? firstAirDate ?? ""
        }
        
        var fullPosterURL: String {
            guard let posterPath = posterPath else { return "" }
            return "https://image.tmdb.org/t/p/w500\(posterPath)"
        }
        
        var fullBackdropURL: String {
            guard let backdropPath = backdropPath else { return "" }
            return "https://image.tmdb.org/t/p/w500\(backdropPath)"
        }
        
        var isMovie: Bool {
            return mediaType == "movie" || title != nil
        }
        
        var isTVShow: Bool {
            return mediaType == "tv" || name != nil
        }
        
        var contentTypeDisplay: String {
            return isTVShow ? "TV Show" : "Movie"
        }
    }
    
    // MARK: - API Methods
    func fetchContent(from endpoint: Endpoint) async throws -> [TMDBContent] {
        let urlString = baseURL + endpoint.path(with: apiKey)
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let tmdbResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return tmdbResponse.results
        } catch {
            print("Decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // MARK: - Mixed Content Methods
    func fetchTrending() async throws -> [TMDBContent] {
        return try await fetchContent(from: .trending)
    }
    
    func search(_ query: String) async throws -> [TMDBContent] {
        return try await fetchContent(from: .search(query: query))
    }
    
    // MARK: - Movie-Specific Methods
    func fetchPopularMovies() async throws -> [TMDBContent] {
        return try await fetchContent(from: .moviePopular)
    }
    
    func fetchTopRatedMovies() async throws -> [TMDBContent] {
        return try await fetchContent(from: .movieTopRated)
    }
    
    // MARK: - TV Show-Specific Methods
    func fetchPopularTVShows() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvPopular)
    }
    
    func fetchTopRatedTVShows() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvTopRated)
    }
    
    func fetchAiringToday() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvAiringToday)
    }
    
    func fetchOnTheAir() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvOnTheAir)
    }
    
    func fetchKDramas() async throws -> [TMDBContent] {
        return try await fetchContent(from: .kdramas)
    }
    
    // MARK: - Backward Compatibility (keeping your existing methods)
    func fetchPopular() async throws -> [TMDBContent] {
        return try await fetchPopularMovies() // Defaults to movies for now
    }
    
    func fetchTopRated() async throws -> [TMDBContent] {
        return try await fetchTopRatedMovies() // Defaults to movies for now
    }
    
    func fetchByGenre(_ genreString: String) async throws -> [TMDBContent] {
        let endpoint: Endpoint
        switch genreString.lowercased() {
        case "action":
            endpoint = .actionMovies
        case "comedy":
            endpoint = .comedyMovies
        case "horror":
            endpoint = .horrorMovies
        case "romance":
            endpoint = .romanceMovies
        case "documentary":
            endpoint = .documentaries
        case "fantasy":           // ADD THIS
            endpoint = .fantasyMovies
        case "animation":         // ADD THIS
            endpoint = .animationMovies
        case "drama tv", "tv drama":
            endpoint = .dramaTVShows
        case "comedy tv", "tv comedy":
            endpoint = .comedyTVShows
        case "kdrama", "k-drama", "korean drama":
            endpoint = .kdramas
        default:
            endpoint = .moviePopular
        }
        return try await fetchContent(from: endpoint)
    }
}
    
    // MARK: - Supporting Types
    enum TMDBError: Error {
        case invalidURL
        case invalidResponse
        case decodingError
    }
    
    // MARK: - Additional Enums and Type Aliases
    enum SearchContentType {
        case movie
        case tv
    }
    
    enum TMDBContentType {
        case movie
        case tvShow
    }


// MARK: - TMDBService Detail Extensions
extension TMDBService {
    
    // MARK: - Movie Details
    
    func fetchMovieDetails(movieId: Int) async throws -> MovieDetailsResponse {
        let url = "\(baseURL)/movie/\(movieId)?api_key=\(apiKey)&append_to_response=credits,videos"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(MovieDetailsResponse.self, from: data)
        } catch {
            print("Movie details decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // MARK: - TV Show Details
    
    func fetchTVShowDetails(tvShowId: Int) async throws -> TVShowDetailsResponse {
        let url = "\(baseURL)/tv/\(tvShowId)?api_key=\(apiKey)&append_to_response=credits,videos"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(TVShowDetailsResponse.self, from: data)
        } catch {
            print("TV show details decoding error: \(error)")
            throw TMDBError.decodingError
        }
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
        let url = "\(baseURL)/\(endpoint)?api_key=\(apiKey)&query=\(encodedQuery)"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let searchResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return searchResponse.results
        } catch {
            print("Search content decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // MARK: - Recommendations
    
    func fetchSimilarContent(for contentId: Int, contentType: TMDBContentType) async throws -> [TMDBContent] {
        let endpoint: String
        
        switch contentType {
        case .movie:
            endpoint = "movie/\(contentId)/similar"
        case .tvShow:
            endpoint = "tv/\(contentId)/similar"
        }
        
        let url = "\(baseURL)/\(endpoint)?api_key=\(apiKey)"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return response.results
        } catch {
            print("Similar content decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    func fetchRecommendedContent(for contentId: Int, contentType: TMDBContentType) async throws -> [TMDBContent] {
        let endpoint: String
        
        switch contentType {
        case .movie:
            endpoint = "movie/\(contentId)/recommendations"
        case .tvShow:
            endpoint = "tv/\(contentId)/recommendations"
        }
        
        let url = "\(baseURL)/\(endpoint)?api_key=\(apiKey)"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return response.results
        } catch {
            print("Recommended content decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
   
    func fetchWatchProviders(for contentId: Int, contentType: TMDBContentType) async throws -> WatchProviders? {
        let typeString = contentType == .movie ? "movie" : "tv"
        let urlString = "\(baseURL)/\(typeString)/\(contentId)/watch/providers?api_key=\(apiKey)"
        
        print("🔍 Fetching watch providers from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Watch providers API error: \(response)")
            throw TMDBError.invalidResponse
        }
        
        do {
            let watchResponse = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)
            let usProviders = watchResponse.results?["US"]
            
            print("📺 Found providers for US:")
            print("   Subscription: \(usProviders?.flatrate?.map { $0.providerName } ?? [])")
            print("   Rental: \(usProviders?.rent?.map { $0.providerName } ?? [])")
            print("   Purchase: \(usProviders?.buy?.map { $0.providerName } ?? [])")
            
            return usProviders
        } catch {
            print("❌ Watch providers decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
}

struct WatchProvidersResponse: Codable {
    let results: [String: WatchProviders]?
}


struct WatchProviders: Codable {
    let link: String?
    let flatrate: [WatchProvider]? // Subscription services
    let rent: [WatchProvider]?     // Rental options
    let buy: [WatchProvider]?      // Purchase options
}

struct WatchProvider: Codable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    
    private enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
    }
}
// MARK: - Detail Response Models

struct MovieDetailsResponse: Codable {
    let id: Int
    let title: String
    let overview: String?
    let runtime: Int?
    let status: String?
    let genres: [TMDBGenre]?
    let spokenLanguages: [TMDBSpokenLanguage]?
    let productionCompanies: [TMDBProductionCompany]?
    let credits: TMDBCreditsResponse?
    let videos: TMDBVideosResponse?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, status, genres, credits, videos
        case spokenLanguages = "spoken_languages"
        case productionCompanies = "production_companies"
    }
}

struct TVShowDetailsResponse: Codable {
    let id: Int
    let name: String
    let overview: String?
    let episodeRunTime: [Int]?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let status: String?
    let genres: [TMDBGenre]?
    let spokenLanguages: [TMDBSpokenLanguage]?
    let productionCompanies: [TMDBProductionCompany]?
    let credits: TMDBCreditsResponse?
    let videos: TMDBVideosResponse?
    
    enum CodingKeys: String, CodingKey {
        case id, name, overview, status, genres, credits, videos
        case episodeRunTime = "episode_run_time"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case spokenLanguages = "spoken_languages"
        case productionCompanies = "production_companies"
    }
}

struct TMDBGenre: Codable {
    let id: Int
    let name: String
}

struct TMDBSpokenLanguage: Codable {
    let name: String
}

struct TMDBProductionCompany: Codable {
    let name: String
}

struct TMDBCreditsResponse: Codable {
    let cast: [TMDBCastMember]?
    let crew: [TMDBCrewMember]?
}

struct TMDBCastMember: Codable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

struct TMDBCrewMember: Codable {
    let id: Int
    let name: String
    let job: String?
    let department: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
    }
}

struct TMDBVideosResponse: Codable {
    let results: [TMDBVideo]?
}

struct TMDBVideo: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

