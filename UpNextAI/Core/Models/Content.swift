import Foundation

enum ContentType: String, CaseIterable, Codable {
    case movie = "movie"
    case tvShow = "tv"
}

enum Genre: String, CaseIterable, Codable {
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
    let id: UUID
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
    
    // Custom initializer for creating new content
    init(tmdbID: Int, title: String, overview: String, releaseDate: Date, genres: [String], contentType: ContentType, posterURL: String? = nil, backdropURL: String? = nil, rating: Double, runtime: Int? = nil, seasons: Int? = nil, streamingAvailability: [StreamingService] = []) {
        self.id = UUID()
        self.tmdbID = tmdbID
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.genres = genres
        self.contentType = contentType
        self.posterURL = posterURL
        self.backdropURL = backdropURL
        self.rating = rating
        self.runtime = runtime
        self.seasons = seasons
        self.streamingAvailability = streamingAvailability
    }
    
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
