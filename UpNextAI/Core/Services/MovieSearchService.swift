import Foundation

class MovieSearchService {
    private let apiClient = TMDBAPIClient.shared
    
    // MARK: - Basic Movie Methods
    func fetchPopularMovies() async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: .moviePopular)
    }
    
    func fetchTopRatedMovies() async throws -> [TMDBContent] {
        return try await apiClient.fetchContent(from: .movieTopRated)
    }
    
    // MARK: - Genre-Based Movie Search
    func fetchMoviesByGenre(_ genre: String) async throws -> [TMDBContent] {
        return try await fetchDiversifiedMovieContent(genre)
    }
    
    func fetchMoviesByGenreWithYear(_ genre: String, yearRange: ClosedRange<Int>) async throws -> [TMDBContent] {
        return try await fetchMovieGenreWithYearFilter(genre, yearRange: yearRange)
    }
    
    // MARK: - Diversified Movie Content
    private func fetchDiversifiedMovieContent(_ genreString: String) async throws -> [TMDBContent] {
        print("🎬 Fetching diversified \(genreString) movies across eras...")
        
        let eraStrategy = getMovieEraStrategy(for: genreString)
        var allResults: [TMDBContent] = []
        var resultCounts: [String: Int] = [:]
        
        for era in eraStrategy.eras {
            do {
                let eraResults = try await fetchMovieGenreFromEra(genreString, era: era)
                let limitedResults = Array(eraResults.prefix(era.maxResults))
                allResults.append(contentsOf: limitedResults)
                resultCounts[era.name] = limitedResults.count
                
                print("📅 \(era.name): \(limitedResults.count) results")
            } catch {
                print("⚠️ Failed to fetch \(era.name) \(genreString): \(error)")
            }
        }
        
        let diversifiedResults = smartMixMovieResults(allResults, strategy: eraStrategy)
        
        print("✅ Final diversified movie results: \(diversifiedResults.count) items")
        print("📊 Era breakdown: \(resultCounts)")
        print("🎬 Sample titles: \(diversifiedResults.prefix(5).map { $0.displayTitle })")
        
        return diversifiedResults
    }
    
    private func fetchMovieGenreFromEra(_ genre: String, era: MovieEra) async throws -> [TMDBContent] {
        let genreId = mapGenreStringToId(genre)
        let startYear = era.yearRange.lowerBound
        let endYear = era.yearRange.upperBound
        let minVotes = era.yearRange.upperBound < 2000 ? 50 : 200
        
        let urlString = "\(apiClient.baseAPIURL)/discover/movie?api_key=\(apiClient.tmdbAPIKey)&with_genres=\(genreId)&primary_release_date.gte=\(startYear)-01-01&primary_release_date.lte=\(endYear)-12-31&sort_by=vote_average.desc&vote_average.gte=\(era.minRating)&vote_count.gte=\(minVotes)&with_original_language=en"
        
        return try await apiClient.fetchURL(urlString)
    }
    
    private func fetchMovieGenreWithYearFilter(_ genreString: String, yearRange: ClosedRange<Int>) async throws -> [TMDBContent] {
        let genreId = mapGenreStringToId(genreString)
        let startYear = yearRange.lowerBound
        let endYear = yearRange.upperBound
        let ratingThreshold = getGenreRatingThreshold([genreString])
        let minVotes = getGenreMinVotes([genreString])
        
        let urlString = "\(apiClient.baseAPIURL)/discover/movie?api_key=\(apiClient.tmdbAPIKey)&with_genres=\(genreId)&primary_release_date.gte=\(startYear)-01-01&primary_release_date.lte=\(endYear)-12-31&sort_by=popularity.desc&vote_average.gte=\(ratingThreshold)&vote_count.gte=\(minVotes)&with_original_language=en&region=US"
        
        print("🔍 Movie year-filtered genre URL: \(urlString)")
        return try await apiClient.fetchURL(urlString)
    }
    
    // MARK: - Multi-Genre Movies
    func fetchMovieGenreCombination(_ genres: [String]) async throws -> [TMDBContent] {
        let genreIds = mapGenresToIds(genres)
        let genreIdsString = genreIds.map(String.init).joined(separator: ",")
        let ratingThreshold = getGenreRatingThreshold(genres)
        let minVotes = getGenreMinVotes(genres)
        let additionalFilters = getAdditionalFilters(genres)
        
        let urlString = "\(apiClient.baseAPIURL)/discover/movie?api_key=\(apiClient.tmdbAPIKey)&with_genres=\(genreIdsString)&sort_by=popularity.desc&vote_average.gte=\(ratingThreshold)&vote_count.gte=\(minVotes)&with_original_language=en&region=US\(additionalFilters)"
        
        print("🔍 Multi-genre movie URL: \(urlString)")
        return try await apiClient.fetchURL(urlString)
    }
    
    // MARK: - Specialized Movie Content
    func fetchSuperheroMovies() async throws -> [TMDBContent] {
        let actionResults = try await apiClient.fetchContent(from: .actionMovies)
        
        let superheroKeywords = [
            "superhero", "super hero", "marvel", "batman", "superman",
            "spider-man", "spider man", "wonder woman", "captain america",
            "iron man", "thor", "hulk", "x-men", "fantastic four",
            "justice league", "avengers", "dc", "comic book", "mcu"
        ]
        
        let filtered = actionResults
            .filter { movie in
                let searchText = "\(movie.displayTitle) \(movie.overview ?? "")".lowercased()
                return superheroKeywords.contains { keyword in
                    searchText.contains(keyword)
                }
            }
            .filter { movie in
                return (movie.voteAverage ?? 0) >= 5.5 && (movie.voteCount ?? 0) >= 150
            }
            .sorted { movie1, movie2 in
                let rating1 = movie1.voteAverage ?? 0
                let votes1 = Double(movie1.voteCount ?? 0)
                let score1 = rating1 * votes1
                
                let rating2 = movie2.voteAverage ?? 0
                let votes2 = Double(movie2.voteCount ?? 0)
                let score2 = rating2 * votes2
                
                return score1 > score2
            }
        
        if filtered.count >= 8 {
            print("🦸‍♂️ Found \(filtered.count) superhero movies from action filter")
            return Array(filtered.prefix(20))
        } else {
            return try await searchSuperheroKeyword()
        }
    }
    
    private func searchSuperheroKeyword() async throws -> [TMDBContent] {
        let queries = ["marvel avengers", "batman superman", "spider-man", "wonder woman"]
        var allResults: [TMDBContent] = []
        
        for query in queries {
            let results = try await apiClient.fetchContent(from: .search(query: query))
            let filtered = results.filter { content in
                let title = content.displayTitle.lowercased()
                let overview = content.overview?.lowercased() ?? ""
                
                let isMovie = content.isMovie
                let hasSuperheroContent = superheroKeywordCheck(title: title, overview: overview)
                let hasGoodRating = (content.voteAverage ?? 0) >= 5.0
                let isEnglish = content.displayTitle.range(of: "[a-zA-Z]", options: .regularExpression) != nil
                
                return isMovie && hasSuperheroContent && hasGoodRating && isEnglish
            }
            allResults.append(contentsOf: filtered)
        }
        
        let uniqueResults = Array(Set(allResults.map { $0.id }))
            .compactMap { id in allResults.first { $0.id == id } }
            .sorted { content1, content2 in
                let rating1 = content1.voteAverage ?? 0
                let votes1 = Double(content1.voteCount ?? 0)
                let score1 = rating1 * votes1
                
                let rating2 = content2.voteAverage ?? 0
                let votes2 = Double(content2.voteCount ?? 0)
                let score2 = rating2 * votes2
                
                return score1 > score2
            }
        
        return Array(uniqueResults.prefix(15))
    }
    
    // MARK: - Helper Methods
    private func getMovieEraStrategy(for genre: String) -> MovieEraStrategy {
        switch genre.lowercased() {
        case "comedy":
            return MovieEraStrategy(
                eras: [
                    MovieEra(name: "Modern", yearRange: 2015...2024, maxResults: 3, minRating: 6.0),
                    MovieEra(name: "2000s-2010s", yearRange: 2000...2014, maxResults: 3, minRating: 6.5),
                    MovieEra(name: "90s Classics", yearRange: 1990...1999, maxResults: 2, minRating: 7.0),
                    MovieEra(name: "80s Gems", yearRange: 1980...1989, maxResults: 2, minRating: 7.0)
                ],
                prioritizeClassics: true
            )
            
        case "drama":
            return MovieEraStrategy(
                eras: [
                    MovieEra(name: "Recent", yearRange: 2015...2024, maxResults: 3, minRating: 6.5),
                    MovieEra(name: "2000s-2010s", yearRange: 2000...2014, maxResults: 3, minRating: 7.0),
                    MovieEra(name: "90s Masterpieces", yearRange: 1990...1999, maxResults: 2, minRating: 7.5),
                    MovieEra(name: "Classic Era", yearRange: 1970...1989, maxResults: 2, minRating: 7.5)
                ],
                prioritizeClassics: true
            )
            
        case "action":
            return MovieEraStrategy(
                eras: [
                    MovieEra(name: "Modern Action", yearRange: 2015...2024, maxResults: 4, minRating: 6.0),
                    MovieEra(name: "2010s Action", yearRange: 2010...2014, maxResults: 3, minRating: 6.5),
                    MovieEra(name: "2000s Action", yearRange: 2000...2009, maxResults: 2, minRating: 6.5),
                    MovieEra(name: "90s-80s Action", yearRange: 1980...1999, maxResults: 1, minRating: 7.0)
                ],
                prioritizeClassics: false
            )
            
        default:
            return MovieEraStrategy(
                eras: [
                    MovieEra(name: "Recent", yearRange: 2015...2024, maxResults: 4, minRating: 6.0),
                    MovieEra(name: "2000s-2010s", yearRange: 2000...2014, maxResults: 3, minRating: 6.5),
                    MovieEra(name: "90s-80s", yearRange: 1980...1999, maxResults: 3, minRating: 6.5)
                ],
                prioritizeClassics: false
            )
        }
    }
    
    private func smartMixMovieResults(_ results: [TMDBContent], strategy: MovieEraStrategy) -> [TMDBContent] {
        let uniqueResults = Array(Set(results.map { $0.id }))
            .compactMap { id in results.first { $0.id == id } }
        
        if strategy.prioritizeClassics {
            return uniqueResults.sorted { content1, content2 in
                let year1 = extractYear(from: content1.displayDate) ?? 2024
                let year2 = extractYear(from: content2.displayDate) ?? 2024
                let rating1 = content1.voteAverage ?? 0
                let rating2 = content2.voteAverage ?? 0
                
                let score1 = rating1 + (year1 < 2000 && rating1 > 7.0 ? 0.5 : 0)
                let score2 = rating2 + (year2 < 2000 && rating2 > 7.0 ? 0.5 : 0)
                
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
    
    private func mapGenreStringToId(_ genreString: String) -> Int {
        let genreMapping: [String: Int] = [
            "action": 28, "adventure": 12, "animation": 16, "comedy": 35,
            "crime": 80, "documentary": 99, "drama": 18, "family": 10751,
            "fantasy": 14, "history": 36, "horror": 27, "music": 10402,
            "mystery": 9648, "romance": 10749, "science fiction": 878,
            "sci-fi": 878, "thriller": 53, "war": 10752, "western": 37
        ]
        return genreMapping[genreString.lowercased()] ?? 35
    }
    
    private func mapGenresToIds(_ genres: [String]) -> [Int] {
        let genreMapping: [String: Int] = [
            "Action": 28, "Adventure": 12, "Animation": 16, "Comedy": 35,
            "Crime": 80, "Documentary": 99, "Drama": 18, "Family": 10751,
            "Fantasy": 14, "History": 36, "Horror": 27, "Music": 10402,
            "Mystery": 9648, "Romance": 10749, "Science Fiction": 878,
            "TV Movie": 10770, "Thriller": 53, "War": 10752, "Western": 37
        ]
        return genres.compactMap { genreMapping[$0] }
    }
    
    private func getGenreRatingThreshold(_ genres: [String]) -> Double {
        if genres.contains("Romance") || genres.contains("Comedy") {
            return 5.5
        }
        if genres.contains("Horror") {
            return 5.8
        }
        if genres.contains("Action") {
            return 6.0
        }
        return 6.5
    }
    
    private func getGenreMinVotes(_ genres: [String]) -> Int {
        if genres.contains("Romance") || genres.contains("Comedy") || genres.contains("Action") {
            return 200
        }
        return 100
    }
    
    private func getAdditionalFilters(_ genres: [String]) -> String {
        if genres.contains("Romance") && genres.contains("Comedy") {
            return "&without_genres=16,18,99,36"
        }
        return ""
    }
    
    private func superheroKeywordCheck(title: String, overview: String) -> Bool {
        let superheroKeywords = [
            "marvel", "batman", "superman", "spider-man", "spider man",
            "wonder woman", "captain america", "iron man", "thor", "hulk",
            "avengers", "justice league", "x-men", "fantastic four",
            "deadpool", "aquaman", "flash", "green lantern", "superhero"
        ]
        
        let searchText = "\(title) \(overview)"
        return superheroKeywords.contains { keyword in
            searchText.contains(keyword)
        }
    }
}

// MARK: - Supporting Types
struct MovieEra {
    let name: String
    let yearRange: ClosedRange<Int>
    let maxResults: Int
    let minRating: Double
}

struct MovieEraStrategy {
    let eras: [MovieEra]
    let prioritizeClassics: Bool
}
