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
        case trending
        case topRated
        case popular
        case actionMovies
        case comedyMovies
        case horrorMovies
        case romanceMovies
        case documentaries
        case search(query: String)
        
        func path(with apiKey: String) -> String {
            switch self {
            case .trending:
                return "/trending/all/week?api_key=\(apiKey)&language=en-US"
            case .topRated:
                return "/movie/top_rated?api_key=\(apiKey)&language=en-US"
            case .popular:
                return "/movie/popular?api_key=\(apiKey)&language=en-US"
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
            case .search(let query):
                return "/search/multi?api_key=\(apiKey)&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
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
    
    // Convenience methods
    func fetchTrending() async throws -> [TMDBContent] {
        return try await fetchContent(from: .trending)
    }
    
    func fetchPopular() async throws -> [TMDBContent] {
        return try await fetchContent(from: .popular)
    }
    
    func fetchTopRated() async throws -> [TMDBContent] {
        return try await fetchContent(from: .topRated)
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
        default:
            endpoint = .popular
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
