//
//  ContentRepositoryProtocol.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import Foundation


// MARK: - Repository Protocol
protocol ContentRepositoryProtocol {
    func fetchTrendingContent() async throws -> [Content]
    func fetchPopularContent() async throws -> [Content]
    func fetchTopRatedContent() async throws -> [Content]
    func fetchContentByGenre(_ genre: String) async throws -> [Content]
    func searchContent(query: String) async throws -> [Content]
}

// MARK: - Content Repository Implementation
class ContentRepository: ContentRepositoryProtocol, ObservableObject {
    private let tmdbService: TMDBService
    private let mapper: TMDBContentMapper
    
    init(tmdbService: TMDBService = TMDBService.shared,
         mapper: TMDBContentMapper = TMDBContentMapper()) {
        self.tmdbService = tmdbService
        self.mapper = mapper
    }
    
    func fetchTrendingContent() async throws -> [Content] {
        let tmdbContent = try await tmdbService.fetchTrending()
        return mapper.mapToDomainModels(tmdbContent)
    }
    
    func fetchPopularContent() async throws -> [Content] {
        let tmdbContent = try await tmdbService.fetchTrending()
        return mapper.mapToDomainModels(tmdbContent)
    }
    
    func fetchTopRatedContent() async throws -> [Content] {
        let tmdbContent = try await tmdbService.fetchTopRatedMovies()
        return mapper.mapToDomainModels(tmdbContent)
    }
    
    func fetchContentByGenre(_ genre: String) async throws -> [Content] {
        let tmdbContent = try await tmdbService.fetchByGenre(genre)
        return mapper.mapToDomainModels(tmdbContent)
    }
    
    func searchContent(query: String) async throws -> [Content] {
        let tmdbContent = try await tmdbService.fetchContent(from: .search(query: query))
        return mapper.mapToDomainModels(tmdbContent)
    }

    func fetchWatchlistContent(tmdbIds: [(id: Int, type: String)]) async throws -> [Content] {
        var watchlistContent: [Content] = []
        
        for item in tmdbIds {
            do {
                let tmdbContent = try await tmdbService.fetchContentById(item.id, type: item.type)
                if let content = mapper.mapToDomainModel(tmdbContent) {
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

// MARK: - TMDB Content Mapper
class TMDBContentMapper {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func mapToDomainModels(_ tmdbContent: [TMDBService.TMDBContent]) -> [Content] {
        return tmdbContent.compactMap { mapToDomainModel($0) }
    }
    
    func mapToDomainModel(_ tmdbContent: TMDBService.TMDBContent) -> Content? {
        // Parse release date
        let releaseDate: Date
        if let dateString = tmdbContent.releaseDate ?? tmdbContent.firstAirDate,
           let parsedDate = dateFormatter.date(from: dateString) {
            releaseDate = parsedDate
        } else {
            releaseDate = Date() // Fallback to current date
        }
        
        // Determine content type
        let contentType: ContentType
        if let mediaType = tmdbContent.mediaType {
            contentType = mediaType == "tv" ? .tvShow : .movie
        } else {
            // If no media type, assume movie (for non-trending endpoints)
            contentType = .movie
        }
        
        // Map genre IDs to genre names (simplified mapping)
        let genres = mapGenreIds(tmdbContent.genreIds ?? [])
        
        return Content(
            tmdbID: tmdbContent.id,
            title: tmdbContent.displayTitle,
            overview: tmdbContent.overview ?? "",
            releaseDate: releaseDate,
            genres: genres,
            contentType: contentType,
            posterURL: tmdbContent.fullPosterURL.isEmpty ? nil : tmdbContent.fullPosterURL,
            backdropURL: tmdbContent.fullBackdropURL.isEmpty ? nil : tmdbContent.fullBackdropURL,
            rating: tmdbContent.voteAverage ?? 5.1,
            runtime: nil, // Would need additional API call to get runtime
            seasons: nil, // Would need additional API call to get seasons
            streamingAvailability: [] // Will implement later with streaming API
        )
    }
    
    private func mapGenreIds(_ genreIds: [Int]) -> [String] {
        // TMDB Genre ID mapping (simplified version)
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
            37: "Western"
        ]
        
        return genreIds.compactMap { genreMap[$0] }
    }
}
