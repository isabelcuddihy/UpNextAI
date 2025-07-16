import Foundation

class TMDBAPIClient {
    static let shared = TMDBAPIClient()
    private init() {}
    
    private let baseURL = "https://api.themoviedb.org/3"
    
    private var apiKey: String {
        return "253293fd6119b5f47cd8bc1307581789"
    }
    
    private var accessToken: String {
        return "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNTMyOTNmZDYxMTliNWY0N2NkOGJjMTMwNzU4MTc4OSIsIm5iZiI6MTcyNTI5OTcyNC40MDg1OTksInN1YiI6IjY2ZDQ5NDViZDk0ZGZmZDhmNzAxZjAwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wm2CLu4jgu5Y-CGNe7XjGWny847vKkExQ0s0J_9jQBY"
    }
    
    // MARK: - Core API Methods
    
    func fetchContent(from endpoint: TMDBEndpoint) async throws -> [TMDBContent] {
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
    
    func fetchURL(_ urlString: String) async throws -> [TMDBContent] {
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
    
    func fetchSingleContent<T: Codable>(_ urlString: String, as type: T.Type) async throws -> T {
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
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // Convenience methods
    var baseAPIURL: String { baseURL }
    var tmdbAPIKey: String { apiKey }
}

// MARK: - Error Types
enum TMDBError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}
