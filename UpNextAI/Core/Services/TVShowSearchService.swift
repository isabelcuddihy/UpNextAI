import Foundation

class TVShowSearchService {
    private let apiClient = TMDBAPIClient.shared
    
    // MARK: - Basic TV Show Methods
    func fetchPopularTVShows() async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: .tvPopular)
    }
    
    func fetchTopRatedTVShows() async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: .tvTopRated)
    }
    
    func fetchAiringToday() async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: .tvAiringToday)
    }
    
    func fetchOnTheAir() async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: .tvOnTheAir)
    }
    
    // MARK: - Genre-Based TV Show Search
    func fetchTVShowsByGenre(_ genre: String) async throws -> [TMDBContent] {
        return try await fetchDiversifiedTVContent(genre)
    }
    
    func fetchTVShowsByGenreWithYear(_ genre: String, yearRange: ClosedRange<Int>) async throws -> [TMDBContent] {
        return try await fetchTVGenreWithYearFilter(genre, yearRange: yearRange)
    }
    
    // MARK: - Specialized TV Show Content
    func fetchKDramas() async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .kdramas)
        return filterToTVShowsOnly(results)
    }
    
    func fetchBritishTVShows() async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .britishTVShows)
        return filterToTVShowsOnly(results)
    }
    
    func fetchTelenovelas() async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .telenovelas)
        return filterToTVShowsOnly(results)
    }
    
    func fetchAnimeTVShows() async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .animeTVShows)
        return filterToTVShowsOnly(results)
    }
    
    func fetchKidsAndFamilyTVShows() async throws -> [TMDBContent] {
        let results = try await apiClient.fetchContent(from: .kidsAndFamilyTVShows)
        return filterToTVShowsOnly(results)
    }
    
    // MARK: - Diversified TV Content
    private func fetchDiversifiedTVContent(_ genreString: String) async throws -> [TMDBContent] {
        print("📺 Fetching diversified \(genreString) TV shows across eras...")
        
        let eraStrategy = getTVEraStrategy(for: genreString)
        var allResults: [TMDBContent] = []
        var resultCounts: [String: Int] = [:]
        
        for era in eraStrategy.eras {
            do {
                let eraResults = try await fetchTVGenreFromEra(genreString, era: era)
                let limitedResults = Array(eraResults.prefix(era.maxResults))
                allResults.append(contentsOf: limitedResults)
                resultCounts[era.name] = limitedResults.count
                
                print("📅 \(era.name): \(limitedResults.count) results")
            } catch {
                print("⚠️ Failed to fetch \(era.name) \(genreString) TV shows: \(error)")
            }
        }
        
        let diversifiedResults = smartMixTVResults(allResults, strategy: eraStrategy)
        let tvOnlyResults = filterToTVShowsOnly(diversifiedResults)
        
        print("✅ Final diversified TV results: \(tvOnlyResults.count) items")
        print("📊 Era breakdown: \(resultCounts)")
        print("📺 Sample titles: \(tvOnlyResults.prefix(5).map { $0.displayTitle })")
        
        return tvOnlyResults
    }
    
    private func fetchTVGenreFromEra(_ genre: String, era: TVEra) async throws -> [TMDBContent] {
        let genreId = mapTVGenreStringToId(genre)
        let startYear = era.yearRange.lowerBound
        let endYear = era.yearRange.upperBound
        let minVotes = era.yearRange.upperBound < 2000 ? 30 : 100  // Lower thresholds for TV
        
        // ✅ Use first_air_date for TV shows, not primary_release_date
        let urlString = "\(apiClient.baseAPIURL)/discover/tv?api_key=\(apiClient.tmdbAPIKey)&with_genres=\(genreId)&first_air_date.gte=\(startYear)-01-01&first_air_date.lte=\(endYear)-12-31&sort_by=vote_average.desc&vote_average.gte=\(era.minRating)&vote_count.gte=\(minVotes)&with_original_language=en"
        
        let results = try await apiClient.fetchURL(urlString)
        return filterToTVShowsOnly(results)
    }
    
    private func fetchTVGenreWithYearFilter(_ genreString: String, yearRange: ClosedRange<Int>) async throws -> [TMDBContent] {
        let genreId = mapTVGenreStringToId(genreString)
        let startYear = yearRange.lowerBound
        let endYear = yearRange.upperBound
        let ratingThreshold = getTVGenreRatingThreshold([genreString])
        let minVotes = getTVGenreMinVotes([genreString])
        
        // ✅ Use first_air_date for TV shows
        let urlString = "\(apiClient.baseAPIURL)/discover/tv?api_key=\(apiClient.tmdbAPIKey)&with_genres=\(genreId)&first_air_date.gte=\(startYear)-01-01&first_air_date.lte=\(endYear)-12-31&sort_by=popularity.desc&vote_average.gte=\(ratingThreshold)&vote_count.gte=\(minVotes)&with_original_language=en"
        
        print("🔍 TV year-filtered genre URL: \(urlString)")
        let results = try await apiClient.fetchURL(urlString)
        return filterToTVShowsOnly(results)
    }
    
    // MARK: - Multi-Genre TV Shows
    func fetchTVGenreCombination(_ genres: [String]) async throws -> [TMDBContent] {
        let genreIds = mapTVGenresToIds(genres)
        let genreIdsString = genreIds.map(String.init).joined(separator: ",")
        let ratingThreshold = getTVGenreRatingThreshold(genres)
        let minVotes = getTVGenreMinVotes(genres)
        
        let urlString = "\(apiClient.baseAPIURL)/discover/tv?api_key=\(apiClient.tmdbAPIKey)&with_genres=\(genreIdsString)&sort_by=popularity.desc&vote_average.gte=\(ratingThreshold)&vote_count.gte=\(minVotes)&with_original_language=en"
        
        print("🔍 Multi-genre TV URL: \(urlString)")
        let results = try await apiClient.fetchURL(urlString)
        return filterToTVShowsOnly(results)
    }
    
    // MARK: - Content Filtering
    private func filterToTVShowsOnly(_ content: [TMDBContent]) -> [TMDBContent] {
        return content.filter { item in
            // Check if it's explicitly marked as TV
            if let mediaType = item.mediaType {
                return mediaType == "tv"
            }
            
            // If no media type, check if it has TV-specific fields
            let hasTVFields = item.name != nil || item.firstAirDate != nil
            let hasMovieFields = item.title != nil || item.releaseDate != nil
            
            // Prefer TV if it has TV fields, even if it also has movie fields
            if hasTVFields {
                return true
            }
            
            // If it only has movie fields, it's probably a movie
            if hasMovieFields && !hasTVFields {
                return false
            }
            
            // Default to including it (better to have false positives than miss content)
            return true
        }
    }
    
    // MARK: - Helper Methods
    private func getTVEraStrategy(for genre: String) -> TVEraStrategy {
        switch genre.lowercased() {
        case "comedy":
            return TVEraStrategy(
                eras: [
                    TVEra(name: "Modern Comedy", yearRange: 2015...2024, maxResults: 4, minRating: 6.0),
                    TVEra(name: "2000s-2010s Comedy", yearRange: 2000...2014, maxResults: 3, minRating: 6.5),
                    TVEra(name: "Classic Sitcoms", yearRange: 1990...1999, maxResults: 2, minRating: 7.0),
                    TVEra(name: "Vintage Comedy", yearRange: 1980...1989, maxResults: 1, minRating: 7.0)
                ],
                prioritizeClassics: true
            )
            
        case "drama":
            return TVEraStrategy(
                eras: [
                    TVEra(name: "Prestige TV", yearRange: 2010...2024, maxResults: 4, minRating: 7.0),
                    TVEra(name: "Golden Age", yearRange: 2000...2009, maxResults: 3, minRating: 7.5),
                    TVEra(name: "Classic Dramas", yearRange: 1990...1999, maxResults: 2, minRating: 7.5),
                    TVEra(name: "Vintage Dramas", yearRange: 1980...1989, maxResults: 1, minRating: 8.0)
                ],
                prioritizeClassics: true
            )
            
        case "crime":
            return TVEraStrategy(
                eras: [
                    TVEra(name: "Modern Crime", yearRange: 2010...2024, maxResults: 4, minRating: 7.0),
                    TVEra(name: "Crime Boom", yearRange: 2000...2009, maxResults: 3, minRating: 7.5),
                    TVEra(name: "Classic Crime", yearRange: 1990...1999, maxResults: 2, minRating: 7.5),
                    TVEra(name: "Vintage Procedurals", yearRange: 1980...1989, maxResults: 1, minRating: 7.0)
                ],
                prioritizeClassics: true
            )
            
        default:
            return TVEraStrategy(
                eras: [
                    TVEra(name: "Recent TV", yearRange: 2015...2024, maxResults: 4, minRating: 6.5),
                    TVEra(name: "2000s-2010s TV", yearRange: 2000...2014, maxResults: 3, minRating: 7.0),
                    TVEra(name: "Classic TV", yearRange: 1990...1999, maxResults: 2, minRating: 7.0),
                    TVEra(name: "Vintage TV", yearRange: 1980...1989, maxResults: 1, minRating: 7.5)
                ],
                prioritizeClassics: false
            )
        }
    }
    
    private func smartMixTVResults(_ results: [TMDBContent], strategy: TVEraStrategy) -> [TMDBContent] {
        let uniqueResults = Array(Set(results.map { $0.id }))
            .compactMap { id in results.first { $0.id == id } }
        
        if strategy.prioritizeClassics {
            return uniqueResults.sorted { content1, content2 in
                let year1 = extractYear(from: content1.firstAirDate ?? content1.displayDate) ?? 2024
                let year2 = extractYear(from: content2.firstAirDate ?? content2.displayDate) ?? 2024
                let rating1 = content1.voteAverage ?? 0
                let rating2 = content2.voteAverage ?? 0
                
                // Classic TV bonus
                let score1 = rating1 + (year1 < 2005 && rating1 > 7.5 ? 0.5 : 0)
                let score2 = rating2 + (year2 < 2005 && rating2 > 7.5 ? 0.5 : 0)
                
                return score1 > score2
            }
        } else {
            return uniqueResults.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
        }
    }
    
    private func extractYear(from dateString: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            return Calendar.current.component(.year, from: date)
        }
        
        return nil
    }
    
    private func mapTVGenreStringToId(_ genreString: String) -> Int {
        // TV-specific genre mapping
        let genreMapping: [String: Int] = [
            "action": 10759,  // Action & Adventure for TV
            "adventure": 10759,
            "animation": 16,
            "comedy": 35,
            "crime": 80,
            "documentary": 99,
            "drama": 18,
            "family": 10751,
            "kids": 10762,    // Kids genre for TV
            "mystery": 9648,
            "news": 10763,
            "reality": 10764,
            "sci-fi": 10765,  // Sci-Fi & Fantasy for TV
            "science fiction": 10765,
            "soap": 10766,
            "talk": 10767,
            "war": 10768,
            "western": 37
        ]
        return genreMapping[genreString.lowercased()] ?? 18  // Default to drama
    }
    
    private func mapTVGenresToIds(_ genres: [String]) -> [Int] {
        return genres.compactMap { mapTVGenreStringToId($0) }
    }
    
    private func getTVGenreRatingThreshold(_ genres: [String]) -> Double {
        // Generally lower rating thresholds for TV since it's evaluated differently
        if genres.contains("Comedy") {
            return 6.0  // Comedy TV shows often rated lower
        }
        if genres.contains("Reality") || genres.contains("Talk") {
            return 5.0  // Reality/Talk shows have different rating patterns
        }
        return 6.5
    }
    
    private func getTVGenreMinVotes(_ genres: [String]) -> Int {
        // Lower vote thresholds for TV content
        return 50
    }
}

// MARK: - Supporting Types
struct TVEra {
    let name: String
    let yearRange: ClosedRange<Int>
    let maxResults: Int
    let minRating: Double
}

struct TVEraStrategy {
    let eras: [TVEra]
    let prioritizeClassics: Bool
}
