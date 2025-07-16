import Foundation

// MARK: - Repository Protocol (no changes needed)
protocol ContentRepositoryProtocol {
    func fetchTrendingContent() async throws -> [Content]
    func fetchPopularContent() async throws -> [Content]
    func fetchTopRatedContent() async throws -> [Content]
    func fetchContentByGenre(_ genre: String) async throws -> [Content]
    func searchContent(query: String) async throws -> [Content]
}

// MARK: - ✅ UPDATED: Content Repository Implementation
class ContentRepository: ContentRepositoryProtocol, ObservableObject {
    private let tmdbService: TMDBService
    private let mapper: TMDBContentMapper
    
    init(tmdbService: TMDBService = TMDBService.shared,
         mapper: TMDBContentMapper = TMDBContentMapper()) {
        self.tmdbService = tmdbService
        self.mapper = mapper
    }
    
    func fetchTrendingContent() async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchTrending()
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func fetchPopularContent() async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchTrending()
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func fetchTopRatedContent() async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchTopRatedMovies()
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    // ✅ ENHANCED: Now supports content type filtering
    func fetchContentByGenre(_ genre: String) async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchByGenre(genre)
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    // ✅ NEW: Content type-aware genre search
    func fetchContentByGenre(_ genre: String, contentType: ContentType) async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchByGenre(genre, contentType: contentType)
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    // ✅ NEW: Year + genre search
    func fetchContentByGenreWithYear(_ genre: String, yearRange: ClosedRange<Int>) async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchByGenreWithYear(genre, yearRange: yearRange)
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func fetchContentByGenreWithYear(_ genre: String, yearRange: ClosedRange<Int>, contentType: ContentType) async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchByGenreWithYear(genre, yearRange: yearRange, contentType: contentType)
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func searchContent(query: String) async throws -> [Content] {
        let TMDBContent = try await tmdbService.search(query)
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    // ✅ NEW: Content type-aware search
    func searchContent(query: String, contentType: ContentType) async throws -> [Content] {
        let TMDBContent = try await tmdbService.search(query)
        // Filter after search since TMDBService.search doesn't support content type yet
        let filtered = TMDBContent.filter { item in
            switch contentType {
            case .movie:
                return item.isMovie
            case .tvShow:
                return item.isTVShow
            case .mixed:
                return true
            }
        }
        return mapper.mapToDomainModels(filtered)
    }
    
    // ✅ NEW: Specialized content fetching methods
    func fetchTVShows() async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchPopularTVShows()
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func fetchMovies() async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchPopularMovies()
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func fetchKDramas() async throws -> [Content] {
        let TMDBContent = try await tmdbService.fetchKDramas()
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    // ✅ ENHANCED: Actor search with content type support
    func searchActorContent(_ actorName: String) async throws -> [Content] {
        let TMDBContent = try await tmdbService.searchActorSimple(actorName)
        return mapper.mapToDomainModels(TMDBContent)
    }
    
    func searchActorContent(_ actorName: String, contentType: ContentType) async throws -> [Content] {
        let TMDBContent = try await tmdbService.searchActorSimple(actorName, contentType: contentType)
        return mapper.mapToDomainModels(TMDBContent)
    }

    func fetchWatchlistContent(tmdbIds: [(id: Int, type: String)]) async throws -> [Content] {
        var watchlistContent: [Content] = []
        
        for item in tmdbIds {
            do {
                let TMDBContent = try await tmdbService.fetchContentById(item.id, type: item.type)
                if let content = mapper.mapToDomainModel(TMDBContent) {
                    watchlistContent.append(content)
                }
            } catch {
                print("Failed to fetch content \(item.id): \(error)")
                // Continue with other items even if one fails
            }
        }
        
        return watchlistContent
    }
}

// MARK: - ✅ ENHANCED: TMDB Content Mapper with better content type detection
class TMDBContentMapper {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func mapToDomainModels(_ TMDBContent: [TMDBContent]) -> [Content] {
        return TMDBContent.compactMap { mapToDomainModel($0) }
    }
    
    func mapToDomainModel(_ TMDBContent: TMDBContent) -> Content? {
        print("🔍 DEBUG: Processing content '\(TMDBContent.displayTitle)'")
        print("🔍 DEBUG: Raw releaseDate: '\(TMDBContent.releaseDate ?? "nil")'")
        print("🔍 DEBUG: Raw firstAirDate: '\(TMDBContent.firstAirDate ?? "nil")'")
        
        let releaseDate: Date
        let dateString = TMDBContent.releaseDate ?? TMDBContent.firstAirDate
        
        print("🔍 DEBUG: Using dateString: '\(dateString ?? "nil")'")
        
        if let dateString = dateString, !dateString.isEmpty {
            if let parsedDate = dateFormatter.date(from: dateString) {
                releaseDate = parsedDate
                print("✅ DEBUG: Successfully parsed date: \(parsedDate) (year: \(Calendar.current.component(.year, from: parsedDate)))")
            } else {
                releaseDate = dateFormatter.date(from: "1900-01-01") ?? Date(timeIntervalSince1970: 0)
                print("❌ DEBUG: Failed to parse date '\(dateString)', using fallback: \(releaseDate)")
            }
        } else {
            releaseDate = dateFormatter.date(from: "1900-01-01") ?? Date(timeIntervalSince1970: 0)
            print("⚠️ DEBUG: No date string found, using fallback: \(releaseDate)")
        }
        
        let finalYear = Calendar.current.component(.year, from: releaseDate)
        print("🔍 DEBUG: Final year for '\(TMDBContent.displayTitle)': \(finalYear)")
        
        // ✅ ENHANCED: Better content type determination
        let contentType: ContentType = determineContentType(from: TMDBContent)
        
        let genres = mapGenreIds(TMDBContent.genreIds ?? [])
        
        return Content(
            tmdbID: TMDBContent.id,
            title: TMDBContent.displayTitle,
            overview: TMDBContent.overview ?? "",
            releaseDate: releaseDate,
            genres: genres,
            contentType: contentType,
            posterURL: TMDBContent.fullPosterURL.isEmpty ? nil : TMDBContent.fullPosterURL,
            backdropURL: TMDBContent.fullBackdropURL.isEmpty ? nil : TMDBContent.fullBackdropURL,
            rating: TMDBContent.voteAverage ?? 5.1,
            runtime: nil,
            seasons: nil,
            streamingAvailability: [],
            genreIds: TMDBContent.genreIds ?? [],
            mediaType: TMDBContent.mediaType,
            posterPath: TMDBContent.posterPath,
            backdropPath: TMDBContent.backdropPath
        )
    }
    
    // ✅ NEW: Enhanced content type determination
    private func determineContentType(from TMDBContent: TMDBContent) -> ContentType {
        // 1. Check explicit media type first
        if let mediaType = TMDBContent.mediaType {
            switch mediaType {
            case "tv":
                print("📺 Content type: TV (from mediaType)")
                return .tvShow
            case "movie":
                print("🎬 Content type: Movie (from mediaType)")
                return .movie
            default:
                break
            }
        }
        
        // 2. Check for TV-specific fields
        let hasTVFields = TMDBContent.name != nil || TMDBContent.firstAirDate != nil
        let hasMovieFields = TMDBContent.title != nil || TMDBContent.releaseDate != nil
        
        if hasTVFields && !hasMovieFields {
            print("📺 Content type: TV (TV fields only)")
            return .tvShow
        }
        
        if hasMovieFields && !hasTVFields {
            print("🎬 Content type: Movie (Movie fields only)")
            return .movie
        }
        
        if hasTVFields && hasMovieFields {
            // Both types of fields present - use heuristics
            
            // Check title patterns that suggest TV shows
            let title = TMDBContent.displayTitle.lowercased()
            let tvIndicators = ["season", "episode", "series", "show", "tv"]
            
            for indicator in tvIndicators {
                if title.contains(indicator) {
                    print("📺 Content type: TV (title contains '\(indicator)')")
                    return .tvShow
                }
            }
            
            // Check overview for TV indicators
            let overview = TMDBContent.overview?.lowercased() ?? ""
            let tvOverviewIndicators = ["season", "episode", "series", "seasons"]
            
            for indicator in tvOverviewIndicators {
                if overview.contains(indicator) {
                    print("📺 Content type: TV (overview contains '\(indicator)')")
                    return .tvShow
                }
            }
            
            // Default to movie if we can't determine
            print("🎬 Content type: Movie (default with mixed fields)")
            return .movie
        }
        
        // Default fallback
        print("🎬 Content type: Movie (default)")
        return .movie
    }
    
    private func mapGenreIds(_ genreIds: [Int]) -> [String] {
        let genreMap: [Int: String] = [
            28: "Action",
            12: "Adventure",
            16: "Animation",
            35: "Comedy",
            80: "Crime",
            99: "Documentary",
            18: "Drama",
            10751: "Family",
            14: "Fantasy",
            36: "History",
            27: "Horror",
            10402: "Music",
            9648: "Mystery",
            10749: "Romance",
            878: "Science Fiction",
            10770: "TV Movie",
            53: "Thriller",
            10752: "War",
            37: "Western",
            
            // TV-specific genres
            10759: "Action & Adventure",
            10762: "Kids",
            10763: "News",
            10764: "Reality",
            10765: "Sci-Fi & Fantasy",
            10766: "Soap",
            10767: "Talk",
            10768: "War & Politics"
        ]
        
        return genreIds.compactMap { genreMap[$0] }
    }
}
