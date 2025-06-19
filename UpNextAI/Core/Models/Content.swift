import Foundation

enum ContentType: String, CaseIterable {
    case movie = "movie"
    case tvShow = "tv"
}

enum Genre: String, CaseIterable {
    case action = "Action"
    case adventure = "Adventure"
    case comedy = "Comedy"
    case drama = "Drama"
    case horror = "Horror"
    case romance = "Romance"
    case sciFi = "Science Fiction"
    case thriller = "Thriller"
    case documentary = "Documentary"
    case animation = "Animation"
    case family = "Family"
    case fantasy = "Fantasy"
}

struct StreamingService: Codable, Hashable {
    let name: String
    let type: String // "subscription", "rent", "buy"
    let price: String?
}

struct Content: Identifiable, Hashable, Codable {
    let id = UUID()
    let tmdbID: Int
    let title: String
    let overview: String
    let releaseDate: Date
    let genres: [String]
    let contentType: ContentType
    let posterURL: String?
    let backdropURL: String?
    let rating: Double
    let runtime: Int? // minutes for movies
    let seasons: Int? // for TV shows
    let streamingAvailability: [StreamingService]
    
    // Computed properties for display
    var formattedDate: String {
        releaseDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    var genreText: String {
        genres.joined(separator: ", ")
    }
    
    var durationText: String {
        if contentType == .movie, let runtime = runtime {
            return "\(runtime) min"
        } else if contentType == .tvShow, let seasons = seasons {
            return "\(seasons) season\(seasons == 1 ? "" : "s")"
        }
        return ""
    }
}
