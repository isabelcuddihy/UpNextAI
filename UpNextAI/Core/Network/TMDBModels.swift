import Foundation

// MARK: - Main Response Models
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
    let voteAverage: Double?
    let genreIds: [Int]?
    let mediaType: String?
    let voteCount: Int?
    
    // Build URLs immediately, not lazily
    let fullPosterURL: String
    let fullBackdropURL: String
    
    var displayVoteAverage: Double {
        return voteAverage ?? 0.0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
        case mediaType = "media_type"
        case voteCount = "vote_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds)
        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount)
        
        // Build URLs immediately
        if let posterPath = posterPath, !posterPath.isEmpty {
            fullPosterURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
        } else {
            fullPosterURL = ""
        }
        
        if let backdropPath = backdropPath, !backdropPath.isEmpty {
            fullBackdropURL = "https://image.tmdb.org/t/p/w500\(backdropPath)"
        } else {
            fullBackdropURL = ""
        }
    }
    
    // Manual initializer
    init(id: Int, title: String?, name: String?, overview: String?, posterPath: String?, backdropPath: String?, releaseDate: String?, firstAirDate: String?, voteAverage: Double?, genreIds: [Int]?, mediaType: String?, voteCount: Int? = nil) {
        self.id = id
        self.title = title
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.firstAirDate = firstAirDate
        self.voteAverage = voteAverage
        self.genreIds = genreIds
        self.mediaType = mediaType
        self.voteCount = voteCount
        
        // Build URLs immediately
        if let posterPath = posterPath, !posterPath.isEmpty {
            fullPosterURL = "https://image.tmdb.org/t/p/w500\(posterPath)"
        } else {
            fullPosterURL = ""
        }
        
        if let backdropPath = backdropPath, !backdropPath.isEmpty {
            fullBackdropURL = "https://image.tmdb.org/t/p/w500\(backdropPath)"
        } else {
            fullBackdropURL = ""
        }
    }
    
    var displayTitle: String {
        return title ?? name ?? "Unknown Title"
    }
    
    var displayDate: String {
        return releaseDate ?? firstAirDate ?? ""
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

// MARK: - Supporting Models
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

// MARK: - Person Search Models
struct PersonSearchResponse: Codable {
    let results: [PersonSearchResult]
}

struct PersonSearchResult: Codable {
    let id: Int
    let name: String
    let popularity: Double?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, popularity
        case profilePath = "profile_path"
    }
}

struct PersonCreditsResponse: Codable {
    let cast: [PersonMovieCredit]
    let crew: [PersonMovieCredit]
}

struct PersonMovieCredit: Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let genreIds: [Int]?
    let character: String?
    let order: Int?
    let voteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, character, order
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
        case voteCount = "vote_count"
    }
}

// MARK: - Watch Providers Models
struct WatchProvidersResponse: Codable {
    let results: [String: WatchProviders]?
}

struct WatchProviders: Codable {
    let link: String?
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
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

// MARK: - Single Content Models
struct MovieSingleResponse: Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
    
    func toTMDBContent() -> TMDBContent {
        return TMDBContent(
            id: id,
            title: title,
            name: nil,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            firstAirDate: nil,
            voteAverage: voteAverage,
            genreIds: genreIds ?? [],
            mediaType: "movie"
        )
    }
}

struct TVShowSingleResponse: Codable {
    let id: Int
    let name: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let firstAirDate: String?
    let voteAverage: Double?
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
    
    func toTMDBContent() -> TMDBContent {
        return TMDBContent(
            id: id,
            title: nil,
            name: name,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: nil,
            firstAirDate: firstAirDate,
            voteAverage: voteAverage,
            genreIds: genreIds ?? [],
            mediaType: "tv"
        )
    }
}

// MARK: - Content Type Enum
enum TMDBContentType {
    case movie
    case tvShow
}
