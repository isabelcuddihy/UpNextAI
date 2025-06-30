import Foundation

enum ContentType: String, CaseIterable, Codable {
    case movie = "movie"
    case tvShow = "tv"
    case mixed = "mixed"
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
    // Existing properties
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
    
    // NEW: TMDB-compatible properties for API calls
    let genreIds: [Int]           // For TMDB API compatibility
    let mediaType: String?        // "movie" or "tv" - matches TMDB format
    let firstAirDate: String?     // For TV shows (TMDB format)
    let posterPath: String?       // Original TMDB poster path
    let backdropPath: String?     // Original TMDB backdrop path
    
    // Custom initializer for creating new content
    init(tmdbID: Int,
         title: String,
         overview: String,
         releaseDate: Date,
         genres: [String],
         contentType: ContentType,
         posterURL: String? = nil,
         backdropURL: String? = nil,
         rating: Double,
         runtime: Int? = nil,
         seasons: Int? = nil,
         streamingAvailability: [StreamingService] = [],
         genreIds: [Int] = [],           // NEW
         mediaType: String? = nil,       // NEW
         firstAirDate: String? = nil,    // NEW
         posterPath: String? = nil,      // NEW
         backdropPath: String? = nil     // NEW
    ) {
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
        self.genreIds = genreIds
        self.mediaType = mediaType
        self.firstAirDate = firstAirDate
        self.posterPath = posterPath
        self.backdropPath = backdropPath
    }
    
    // Existing computed properties for display
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
    
    // NEW: TMDB-compatible computed properties for ViewModel
    var displayTitle: String {
        return title
    }
    
    var displayDate: String {
        return releaseDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    var isMovie: Bool {
        return contentType == .movie
    }
    
    var isTVShow: Bool {
        return contentType == .tvShow
    }
    
    var voteAverage: Double {
        return rating
    }
    
    // NEW: Full URL properties that match TMDB format
    var fullPosterURL: String {
        guard let posterPath = posterPath else { return posterURL ?? "" }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var fullBackdropURL: String {
        guard let backdropPath = backdropPath else { return backdropURL ?? "" }
        return "https://image.tmdb.org/t/p/w500\(backdropPath)"
    }
    
    // Helper to format date for TMDB API
    private var releaseDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: releaseDate)
    }

    func toTMDBContent() -> TMDBService.TMDBContent {
        return TMDBService.TMDBContent(
            id: self.tmdbID,
            title: self.contentType == .movie ? self.title : nil,
            name: self.contentType == .tvShow ? self.title : nil,
            overview: self.overview,
            posterPath: self.posterPath,
            backdropPath: self.backdropPath,
            releaseDate: self.contentType == .movie ? self.releaseDateString : nil,
            firstAirDate: self.firstAirDate,
            voteAverage: self.rating,
            genreIds: self.genreIds,
            mediaType: self.mediaType
        )
    }
}
