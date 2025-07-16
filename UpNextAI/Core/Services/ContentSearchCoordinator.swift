//
//  ContentSearchCoordinator.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 7/12/25.
//
import Foundation

class ContentSearchCoordinator {
    private let apiClient = TMDBAPIClient.shared
    private let movieService = MovieSearchService()
    private let tvService = TVShowSearchService()
    
    // MARK: - Main Search Methods
    
    func fetchByGenre(_ genre: String, contentType: ContentType? = nil) async throws -> [TMDBContent] {
        print("🎭 ContentSearchCoordinator: Fetching \(genre) with type: \(contentType?.rawValue ?? "mixed")")
        
        // Handle specific combinations first
        switch genre.lowercased() {
        case "romantic comedy", "romantic comedies", "rom com", "rom-com":
            if contentType == .tvShow {
                return try await tvService.fetchTVGenreCombination(["Romance", "Comedy"])
            } else {
                return try await movieService.fetchMovieGenreCombination(["Romance", "Comedy"])
            }
            
        case "superhero":
            if contentType == .tvShow {
                return try await apiClient.fetchContent(from: .superheroTVShows)
            } else {
                return try await movieService.fetchSuperheroMovies()
            }
        default:
            break // Continue to specialized content handling
        }
        
        // Handle specialized regional/language content
        if let specializedResult = try await handleSpecializedContent(genre, contentType: contentType) {
            return specializedResult
        }
        
        // Handle main genres with content type routing
        return try await routeGenreSearch(genre, contentType: contentType)
    }
    
    func fetchByGenreWithYear(_ genre: String, yearRange: ClosedRange<Int>, contentType: ContentType? = nil) async throws -> [TMDBContent] {
        print("🎭 ContentSearchCoordinator: Fetching \(genre) from \(yearRange) with type: \(contentType?.rawValue ?? "mixed")")
        
        switch contentType {
        case .movie:
            return try await movieService.fetchMoviesByGenreWithYear(genre, yearRange: yearRange)
        case .tvShow:
            return try await tvService.fetchTVShowsByGenreWithYear(genre, yearRange: yearRange)
        case .mixed:
            // For mixed searches, combine both but limit results
            async let movieResults = try movieService.fetchMoviesByGenreWithYear(genre, yearRange: yearRange)
            async let tvResults = try tvService.fetchTVShowsByGenreWithYear(genre, yearRange: yearRange)
            
            let movies = Array((try await movieResults).prefix(5))
            let tvShows = Array((try await tvResults).prefix(5))
            
            return interleaveResults(movies: movies, tvShows: tvShows)
        case .none:
            // For mixed searches, combine both but limit results
            async let movieResults = try movieService.fetchMoviesByGenreWithYear(genre, yearRange: yearRange)
            async let tvResults = try tvService.fetchTVShowsByGenreWithYear(genre, yearRange: yearRange)
            
            let movies = Array((try await movieResults).prefix(5))
            let tvShows = Array((try await tvResults).prefix(5))
            
            return movies + tvShows
        }
    }
    
    func search(_ query: String, contentType: ContentType? = nil) async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .search(query: query))
        return filterByContentType(results, contentType: contentType)
    }
    
    func fetchTrending(contentType: ContentType? = nil) async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .trending)
        return filterByContentType(results, contentType: contentType)
    }
    
    // MARK: - Actor Search
    func searchActorSimple(_ actorName: String, contentType: ContentType? = nil) async throws -> [TMDBContent] {
        print("🎭 Searching for actor movies: \(actorName)")
        
        // Step 1: Search for the person to get their ID
        if let personId = try await searchPersonId(actorName) {
            print("✅ Found person ID: \(personId), fetching credits...")
            let credits = try await fetchPersonCredits(personId, contentType: contentType)
            return credits
        } else {
            print("⚠️ Person not found, using keyword search fallback")
            return try await searchActorKeywordFallback(actorName, contentType: contentType)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func handleSpecializedContent(_ genre: String, contentType: ContentType?) async throws -> [TMDBContent]? {
        switch genre.lowercased() {
        // TV-specific specializations
        case "britishtvshows", "british tv", "british tv shows":
            return try await tvService.fetchBritishTVShows()
        case "kdramas", "k-drama", "kdrama", "korean dramas":
            return try await tvService.fetchKDramas()
        case "telenovelas":
            return try await tvService.fetchTelenovelas()
        case "animetvshows", "anime tv", "anime shows":
            return try await tvService.fetchAnimeTVShows()
            
        // Movie-specific specializations
        case "bollywood":
            if contentType == .tvShow { return [] } // No Bollywood TV endpoint
            return try await apiClient.fetchContent(from: .bollywoodMovies)
        case "anime" where contentType != .tvShow:
            return try await apiClient.fetchContent(from: .animeMovies)
            
        // Family content (both)
        case "kids & family", "kids and family":
            if contentType == .tvShow {
                return try await tvService.fetchKidsAndFamilyTVShows()
            } else {
                return try await apiClient.fetchContent(from: .kidsAndFamilyMovies)
            }
            
        default:
            return nil
        }
    }
    
    private func routeGenreSearch(_ genre: String, contentType: ContentType?) async throws -> [TMDBContent] {
        switch contentType {
        case .movie:
            print("🎬 Routing to movie service for \(genre)")
            return try await movieService.fetchMoviesByGenre(genre)
            
        case .tvShow:
            print("📺 Routing to TV service for \(genre)")
            return try await tvService.fetchTVShowsByGenre(genre)
            
        case .mixed:
            print("🎭 Mixed content search for \(genre)")
            // For mixed searches, get from both services but limit results
            async let movieResults = try movieService.fetchMoviesByGenre(genre)
            async let tvResults = try tvService.fetchTVShowsByGenre(genre)
            
            let movies = Array((try await movieResults).prefix(5))
            let tvShows = Array((try await tvResults).prefix(5))
            
            // Interleave the results for variety
            return interleaveResults(movies: movies, tvShows: tvShows)
            
        case .none:
            print("🎭 Mixed content search for \(genre)")
            // For mixed searches, get from both services but limit results
            async let movieResults = try movieService.fetchMoviesByGenre(genre)
            async let tvResults = try tvService.fetchTVShowsByGenre(genre)
            
            let movies = Array((try await movieResults).prefix(5))
            let tvShows = Array((try await tvResults).prefix(5))
            
            // Interleave the results for variety
            return interleaveResults(movies: movies, tvShows: tvShows)
        }
    }
    
    private func filterByContentType(_ content: [TMDBContent], contentType: ContentType?) -> [TMDBContent] {
        guard let contentType = contentType else { return content }
        
        return content.filter { item in
            switch contentType {
            case .movie:
                return item.isMovie
            case .tvShow:
                return item.isTVShow
            case .mixed:
                return true // Return all content for mixed type
            }
        }
    }
    
    private func interleaveResults(movies: [TMDBContent], tvShows: [TMDBContent]) -> [TMDBContent] {
        var result: [TMDBContent] = []
        let maxCount = max(movies.count, tvShows.count)
        
        for i in 0..<maxCount {
            if i < movies.count {
                result.append(movies[i])
            }
            if i < tvShows.count {
                result.append(tvShows[i])
            }
        }
        
        return result
    }
    
    // MARK: - Actor Search Implementation
    
    private func searchPersonId(_ actorName: String) async throws -> Int? {
        let encodedName = actorName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(apiClient.baseAPIURL)/search/person?api_key=\(apiClient.tmdbAPIKey)&query=\(encodedName)"
        
        let personResponse = try await apiClient.fetchSingleContent(urlString, as: PersonSearchResponse.self)
        
        let topResult = personResponse.results
            .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
            .first
        
        print("🔍 Person search results: \(personResponse.results.map { $0.name })")
        return topResult?.id
    }
    
    private func fetchPersonCredits(_ personId: Int, contentType: ContentType?) async throws -> [TMDBContent] {
        // Determine which credits to fetch based on content type
        let endpoint: String
        switch contentType {
        case .movie:
            endpoint = "/person/\(personId)/movie_credits"
        case .tvShow:
            endpoint = "/person/\(personId)/tv_credits"
        case .mixed:
            endpoint = "/person/\(personId)/combined_credits"
        case .none:
            endpoint = "/person/\(personId)/combined_credits"
        }
        
        let urlString = "\(apiClient.baseAPIURL)\(endpoint)?api_key=\(apiClient.tmdbAPIKey)"
        
        let creditsResponse = try await apiClient.fetchSingleContent(urlString, as: PersonCreditsResponse.self)
        
        let movieCredits = creditsResponse.cast
            .filter { credit in
                let hasGoodRating = (credit.voteAverage ?? 0) > 5.5
                let isMainRole = (credit.order ?? 999) < 10
                let hasVotes = (credit.voteCount ?? 0) > 100
                
                return hasGoodRating && isMainRole && hasVotes
            }
            .sorted { credit1, credit2 in
                let score1 = (credit1.voteAverage ?? 0) * Double(credit1.voteCount ?? 0)
                let score2 = (credit2.voteAverage ?? 0) * Double(credit2.voteCount ?? 0)
                return score1 > score2
            }
            .prefix(12)
            .map { credit in
                TMDBContent(
                    id: credit.id,
                    title: credit.title,
                    name: nil,
                    overview: credit.overview,
                    posterPath: credit.posterPath,
                    backdropPath: credit.backdropPath,
                    releaseDate: credit.releaseDate,
                    firstAirDate: nil,
                    voteAverage: credit.voteAverage,
                    genreIds: credit.genreIds,
                    mediaType: contentType == .tvShow ? "tv" : "movie",
                    voteCount: credit.voteCount
                )
            }
        
        print("🎬 Found \(movieCredits.count) quality credits for actor")
        return Array(movieCredits)
    }
    
    private func searchActorKeywordFallback(_ actorName: String, contentType: ContentType?) async throws -> [TMDBContent] {
        let searchQueries = ["\(actorName) movie", actorName, "\(actorName) film"]
        
        for query in searchQueries {
            let results = try await search(query, contentType: contentType)
            let filtered = results.filter { content in
                let title = content.displayTitle.lowercased()
                let overview = content.overview?.lowercased() ?? ""
                
                let isDocumentary = title.contains("documentary") ||
                                  title.contains("biography") ||
                                  overview.contains("documentary about")
                
                let hasGoodRating = (content.voteAverage ?? 0) > 5.0
                
                return !isDocumentary && hasGoodRating
            }
            .sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
            
            if filtered.count >= 3 {
                print("✅ Keyword search '\(query)' found \(filtered.count) filtered results")
                return Array(filtered.prefix(10))
            }
        }
        
        return []
    }
}
