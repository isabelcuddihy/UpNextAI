import Foundation

class TMDBService {
    static let shared = TMDBService()
    private init() {}
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    private var apiKey: String {
        return "253293fd6119b5f47cd8bc1307581789"
    }
    
    private var accessToken: String {
        return "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNTMyOTNmZDYxMTliNWY0N2NkOGJjMTMwNzU4MTc4OSIsIm5iZiI6MTcyNTI5OTcyNC40MDg1OTksInN1YiI6IjY2ZDQ5NDViZDk0ZGZmZDhmNzAxZjAwMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wm2CLu4jgu5Y-CGNe7XjGWny847vKkExQ0s0J_9jQBY"
    }
    
    // MARK: - API Endpoints
    enum Endpoint {
        // Mixed content
        case trending
        case search(query: String)
        
        // Movie-specific endpoints
        case moviePopular
        case movieTopRated
        case actionMovies
        case comedyMovies
        case horrorMovies
        case romanceMovies
        case documentaries
        case fantasyMovies
        case animationMovies
        
        // NEW MOVIE ENDPOINTS
        case superheroMovies
        case historicalMovies
        case trueCrimeDocumentaries
        case bollywoodMovies
        case animeMovies  // Update from animationMovies
        case kidsAndFamilyMovies
        
        // TV-specific endpoints
        case tvPopular
        case tvTopRated
        case tvAiringToday
        case tvOnTheAir
        case actionTVShows
        case comedyTVShows
        case dramaTVShows
        case crimeTV  // Remove or rename to trueCrimeTV
        case kdramas
        
        // NEW TV ENDPOINTS
        case superheroTVShows
        case historicalTVShows
        case trueCrimeTVShows
        case britishTVShows
        case telenovelas
        case animeTVShows
        case kidsAndFamilyTVShows
        
        // Movie-specific endpoints (add these)
        case sciFiMovies
        case thrillerMovies
        case adventureMovies
        case mysteryMovies

        // TV-specific endpoints (add these)
        case sciFiTVShows
        case thrillerTVShows
        case adventureTVShows
        case mysteryTVShows
        
        func path(with apiKey: String) -> String {
            switch self {
                // Mixed content
            case .trending:
                return "/trending/all/week?api_key=\(apiKey)&language=en-US"
            case .search(let query):
                return "/search/multi?api_key=\(apiKey)&language=en-US&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                
                // Movie endpoints
            case .moviePopular:
                return "/movie/popular?api_key=\(apiKey)&language=en-US"
            case .movieTopRated:
                return "/movie/top_rated?api_key=\(apiKey)&language=en-US"
            case .actionMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=28"
            case .comedyMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=35"
            case .horrorMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=27"
            case .romanceMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=10749"
            case .documentaries:
                return "/discover/movie?api_key=\(apiKey)&with_genres=99"
                
            case .fantasyMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=14"  // Fantasy genre ID
            case .animationMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=16"  // Animation genre ID
                
            case .superheroMovies:
                return "/discover/movie?api_key=\(apiKey)&with_keywords=superhero"
            case .historicalMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=36"  // History genre
            case .trueCrimeDocumentaries:
                return "/discover/movie?api_key=\(apiKey)&with_genres=99&with_keywords=true-crime"  // Documentary + true crime
            case .bollywoodMovies:
                return "/discover/movie?api_key=\(apiKey)&with_origin_country=IN&with_original_language=hi"  // India + Hindi
            case .animeMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=16&with_origin_country=JP"  // Animation + Japan
            case .kidsAndFamilyMovies:
                return "/discover/movie?api_key=\(apiKey)&with_genres=10751"  // Family genre
                
                // Movie endpoints
                case .sciFiMovies:
                    return "/discover/movie?api_key=\(apiKey)&with_genres=878"  // Science Fiction
                case .thrillerMovies:
                    return "/discover/movie?api_key=\(apiKey)&with_genres=53"   // Thriller
                case .adventureMovies:
                    return "/discover/movie?api_key=\(apiKey)&with_genres=12"   // Adventure
                case .mysteryMovies:
                    return "/discover/movie?api_key=\(apiKey)&with_genres=9648" // Mystery
                
                // TV endpoints
            case .tvPopular:
                return "/tv/popular?api_key=\(apiKey)&language=en-US"
            case .tvTopRated:
                return "/tv/top_rated?api_key=\(apiKey)&language=en-US"
            case .tvAiringToday:
                return "/tv/airing_today?api_key=\(apiKey)&language=en-US"
            case .tvOnTheAir:
                return "/tv/on_the_air?api_key=\(apiKey)&language=en-US"
            case .actionTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=10759" // Action & Adventure
            case .comedyTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=35"
            case .dramaTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=18"
            case .crimeTV:
                return "/discover/tv?api_key=\(apiKey)&with_genres=80"
            case .kdramas:
                return "/discover/tv?api_key=\(apiKey)&with_genres=18&with_origin_country=KR" // Korean dramas
                
            case .superheroTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_keywords=superhero"
            case .historicalTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=36"  // History genre
            case .trueCrimeTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=99&with_keywords=true-crime"  // Documentary + true crime
            case .britishTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_origin_country=GB"  // Great Britain
            case .telenovelas:
                return "/discover/tv?api_key=\(apiKey)&with_original_language=es&with_genres=18"  // Spanish + Drama
            case .animeTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=16&with_origin_country=JP"  // Animation + Japan
            case .kidsAndFamilyTVShows:
                return "/discover/tv?api_key=\(apiKey)&with_genres=10762"  // Kids genre for TV

                // TV endpoints
                case .sciFiTVShows:
                    return "/discover/tv?api_key=\(apiKey)&with_genres=10765"   // Sci-Fi & Fantasy for TV
                case .thrillerTVShows:
                    return "/discover/tv?api_key=\(apiKey)&with_genres=9648"    // Mystery for TV (close to thriller)
                case .adventureTVShows:
                    return "/discover/tv?api_key=\(apiKey)&with_genres=10759"   // Action & Adventure for TV
                case .mysteryTVShows:
                    return "/discover/tv?api_key=\(apiKey)&with_genres=9648"    // Mystery for TV
            }
        }
    }
    
    // MARK: - Response Models
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
        let voteCount: Int? // NEW: For popularity sorting
        
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
            case voteCount = "vote_count" // NEW
        }
        
        // Custom initializer to build URLs eagerly
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
            genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) // FIXED: Optional
            mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
            voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) // NEW
            
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
        
        // Manual initializer for when we create TMDBContent manually
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
            self.voteCount = voteCount // NEW
            
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
        
        // Helper computed properties remain the same...
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
    
    // MARK: - API Methods
    func fetchContent(from endpoint: Endpoint) async throws -> [TMDBContent] {
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
    
    // MARK: - Mixed Content Methods
    func fetchTrending() async throws -> [TMDBContent] {
        return try await fetchContent(from: .trending)
    }
    
    func search(_ query: String) async throws -> [TMDBContent] {
        return try await fetchContent(from: .search(query: query))
    }
    
    // MARK: - Movie-Specific Methods
    func fetchPopularMovies() async throws -> [TMDBContent] {
        return try await fetchContent(from: .moviePopular)
    }
    
    func fetchTopRatedMovies() async throws -> [TMDBContent] {
        return try await fetchContent(from: .movieTopRated)
    }
    
    // MARK: - TV Show-Specific Methods
    func fetchPopularTVShows() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvPopular)
    }
    
    func fetchTopRatedTVShows() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvTopRated)
    }
    
    func fetchAiringToday() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvAiringToday)
    }
    
    func fetchOnTheAir() async throws -> [TMDBContent] {
        return try await fetchContent(from: .tvOnTheAir)
    }
    
    func fetchKDramas() async throws -> [TMDBContent] {
        return try await fetchContent(from: .kdramas)
    }
    


    func fetchByGenre(_ genreString: String) async throws -> [TMDBContent] {
        print("🎬 Fetching genre: \(genreString)")
        
        let endpoint: Endpoint
        switch genreString.lowercased() {
            // Handle specific genre combinations FIRST
        case "romantic comedy", "romantic comedies", "rom com", "rom-com":
            return try await fetchGenreCombination(["Romance", "Comedy"], contentType: .movie)
            
        case "horror comedy", "horror comedies":
            return try await fetchGenreCombination(["Horror", "Comedy"], contentType: .movie)
            
        case "action thriller", "action thrillers":
            return try await fetchGenreCombination(["Action", "Thriller"], contentType: .movie)
            
        case "sci-fi thriller", "scifi thriller":
            return try await fetchGenreCombination(["Science Fiction", "Thriller"], contentType: .movie)
            
            // FIXED: Superhero mapping
        case "superhero":
            return try await fetchSuperheroContent()
            
            // Original single genres (unchanged)
        case "action":
            endpoint = .actionMovies
        case "comedy":
            endpoint = .comedyMovies
        case "horror":
            endpoint = .horrorMovies
        case "romance":
            endpoint = .romanceMovies
        case "documentary":
            endpoint = .documentaries
        case "fantasy":
            endpoint = .fantasyMovies
        case "animation":
            endpoint = .animationMovies
        case "drama":
            endpoint = .dramaTVShows
        case "thriller":
            endpoint = .thrillerMovies
        case "adventure":
            endpoint = .adventureMovies
        case "mystery":
            endpoint = .mysteryMovies
        case "sci-fi", "science fiction":
            endpoint = .sciFiMovies
        case "crime", "true crime":
            endpoint = .crimeTV
            
            // Other existing genres...
        case "historical":
            endpoint = .historicalMovies
        case "bollywood":
            endpoint = .bollywoodMovies
        case "anime":
            endpoint = .animeMovies
        case "kids & family", "kids and family":
            endpoint = .kidsAndFamilyMovies
        case "k-drama", "kdrama":
            endpoint = .kdramas
        case "british tv":
            endpoint = .britishTVShows
        case "telenovelas":
            endpoint = .telenovelas
            
        default:
            endpoint = .moviePopular
        }
        
        return try await fetchContent(from: endpoint)
    }

    // NEW: Handle multiple genre combinations
    func fetchGenreCombination(_ genres: [String], contentType: TMDBContentType) async throws -> [TMDBContent] {
        let genreIds = mapGenresToIds(genres)
        let genreIdsString = genreIds.map(String.init).joined(separator: ",")
        
        let baseURL = contentType == .movie ?
            "/discover/movie?api_key=\(apiKey)" :
            "/discover/tv?api_key=\(apiKey)"
        
        // Enhanced filtering for better results
        let ratingThreshold = getGenreRatingThreshold(genres)
        let minVotes = getGenreMinVotes(genres)
        
        // Add additional filters for rom-coms to get mainstream results
        let additionalFilters = getAdditionalFilters(genres)
        
        let urlString = "\(self.baseURL)\(baseURL)&with_genres=\(genreIdsString)&sort_by=popularity.desc&vote_average.gte=\(ratingThreshold)&vote_count.gte=\(minVotes)&with_original_language=en&region=US\(additionalFilters)"
        
        print("🔍 Multi-genre URL: \(urlString)")
        
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
            let results = tmdbResponse.results
            
            print("✅ Found \(results.count) results for \(genres) combination")
            print("📍 Top 3: \(results.prefix(3).map { $0.displayTitle })")
            
            return results
        } catch {
            print("❌ Multi-genre decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }

    // NEW: Map genre names to TMDB IDs
    private func mapGenresToIds(_ genres: [String]) -> [Int] {
        let genreMapping: [String: Int] = [
            "Action": 28,
            "Adventure": 12,
            "Animation": 16,
            "Comedy": 35,
            "Crime": 80,
            "Documentary": 99,
            "Drama": 18,
            "Family": 10751,
            "Fantasy": 14,
            "History": 36,
            "Horror": 27,
            "Music": 10402,
            "Mystery": 9648,
            "Romance": 10749,
            "Science Fiction": 878,
            "TV Movie": 10770,
            "Thriller": 53,
            "War": 10752,
            "Western": 37
        ]
        
        return genres.compactMap { genreMapping[$0] }
    }

    // FIXED: Superhero content with better filtering
    private func fetchSuperheroContent() async throws -> [TMDBContent] {
        // First try: Use action movies with popularity sorting
        let actionEndpoint = Endpoint.actionMovies
        let actionResults = try await fetchContent(from: actionEndpoint)
        
        let superheroKeywords = [
            "superhero", "super hero", "marvel", "batman", "superman",
            "spider-man", "spider man", "wonder woman", "captain america",
            "iron man", "thor", "hulk", "x-men", "fantastic four",
            "justice league", "avengers", "dc", "comic book", "mcu"
        ]
        
        // Filter for superhero content, prioritizing popularity
        let filtered = actionResults
            .filter { movie in
                let searchText = "\(movie.displayTitle) \(movie.overview ?? "")".lowercased()
                return superheroKeywords.contains { keyword in
                    searchText.contains(keyword)
                }
            }
            .filter { movie in
                // Lower rating threshold for superhero movies (entertainment > critics)
                return (movie.voteAverage ?? 0) >= 5.5 && (movie.voteCount ?? 0) >= 150
            }
            .sorted { movie1, movie2 in
                // Sort by popularity score (rating * vote count) - broken down for compiler
                let rating1 = movie1.voteAverage ?? 0
                let votes1 = Double(movie1.voteCount ?? 0)
                let score1 = rating1 * votes1
                
                let rating2 = movie2.voteAverage ?? 0
                let votes2 = Double(movie2.voteCount ?? 0)
                let score2 = rating2 * votes2
                
                return score1 > score2
            }
        
        if filtered.count >= 5 {
            print("🦸‍♂️ Found \(filtered.count) superhero movies from action filter")
            print("🦸‍♂️ Top results: \(filtered.prefix(5).map { $0.displayTitle })")
            return Array(filtered.prefix(15))
        } else {
            // Fallback: Direct keyword search
            print("🦸‍♂️ Action filter insufficient, trying keyword search...")
            return try await searchSuperheroKeyword()
        }
    }

    private func searchSuperheroKeyword() async throws -> [TMDBContent] {
        // Try multiple specific superhero searches instead of one broad search
        let queries = [
            "marvel avengers",
            "batman superman",
            "spider-man",
            "wonder woman"
        ]
        
        var allResults: [TMDBContent] = []
        
        for query in queries {
            let results = try await search(query)
            let filtered = results.filter { content in
                let title = content.displayTitle.lowercased()
                let overview = content.overview?.lowercased() ?? ""
                
                // Must be a movie and have superhero keywords
                let isMovie = content.isMovie
                let hasSuperheroContent = superheroKeywordCheck(title: title, overview: overview)
                let hasGoodRating = (content.voteAverage ?? 0) >= 5.0
                let isEnglish = content.displayTitle.range(of: "[a-zA-Z]", options: .regularExpression) != nil
                
                return isMovie && hasSuperheroContent && hasGoodRating && isEnglish
            }
            allResults.append(contentsOf: filtered)
        }
        
        // Remove duplicates and sort by popularity
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
        
        print("🦸‍♂️ Keyword search found \(uniqueResults.count) superhero movies")
        print("🦸‍♂️ Results: \(uniqueResults.prefix(5).map { $0.displayTitle })")
        
        return Array(uniqueResults.prefix(10))
    }

    // Genre-specific thresholds based on real-world patterns
    private func getGenreRatingThreshold(_ genres: [String]) -> Double {
        // Rom-coms, horror comedies, action movies often get lower critic scores
        // but high audience engagement - adjust thresholds accordingly
        
        if genres.contains("Romance") || genres.contains("Comedy") {
            return 5.5  // Lower bar for rom-coms and comedies
        }
        
        if genres.contains("Horror") {
            return 5.8  // Horror gets mixed critical reception
        }
        
        if genres.contains("Action") {
            return 6.0  // Action movies prioritize entertainment over critics
        }
        
        // Dramas, documentaries, etc. keep higher standards
        return 6.5
    }

    private func getGenreMinVotes(_ genres: [String]) -> Int {
        // Popularity-focused genres need more audience engagement
        if genres.contains("Romance") || genres.contains("Comedy") || genres.contains("Action") {
            return 200  // Higher vote count = more mainstream appeal
        }
        
        return 100  // Standard threshold
    }

    // NEW: Additional filters for specific genre combinations
    private func getAdditionalFilters(_ genres: [String]) -> String {
        // For romantic comedies, exclude art house and drama-heavy films
        if genres.contains("Romance") && genres.contains("Comedy") {
            return "&without_genres=16,18,99,36" // Exclude Anime, Drama, Documentary, History
        }
        
        return ""
    }


    // Helper function for superhero keyword checking
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
    enum TMDBError: Error {
        case invalidURL
        case invalidResponse
        case decodingError
    }
    
    // MARK: - Additional Enums and Type Aliases
    enum SearchContentType {
        case movie
        case tv
    }
    
    enum TMDBContentType {
        case movie
        case tvShow
    }


// MARK: - TMDBService Detail Extensions
extension TMDBService {
    
    // MARK: - Movie Details
    
    func fetchMovieDetails(movieId: Int) async throws -> MovieDetailsResponse {
        let url = "\(baseURL)/movie/\(movieId)?api_key=\(apiKey)&append_to_response=credits,videos"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(MovieDetailsResponse.self, from: data)
        } catch {
            print("Movie details decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // MARK: - TV Show Details
    
    func fetchTVShowDetails(tvShowId: Int) async throws -> TVShowDetailsResponse {
        let url = "\(baseURL)/tv/\(tvShowId)?api_key=\(apiKey)&append_to_response=credits,videos"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(TVShowDetailsResponse.self, from: data)
        } catch {
            print("TV show details decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // MARK: - Search with Content Type
    
    func searchContent(query: String, contentType: SearchContentType? = nil) async throws -> [TMDBContent] {
        let endpoint: String
        
        switch contentType {
        case .movie:
            endpoint = "search/movie"
        case .tv:
            endpoint = "search/tv"
        case .none:
            endpoint = "search/multi"
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = "\(baseURL)/\(endpoint)?api_key=\(apiKey)&query=\(encodedQuery)"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let searchResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return searchResponse.results
        } catch {
            print("Search content decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // MARK: - Recommendations
    
    func fetchSimilarContent(for contentId: Int, contentType: TMDBContentType) async throws -> [TMDBContent] {
        let endpoint: String
        
        switch contentType {
        case .movie:
            endpoint = "movie/\(contentId)/similar"
        case .tvShow:
            endpoint = "tv/\(contentId)/similar"
        }
        
        let url = "\(baseURL)/\(endpoint)?api_key=\(apiKey)"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return response.results
        } catch {
            print("Similar content decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    private func fetchRecommendedContent(for contentId: Int, contentType: TMDBContentType) async throws -> [TMDBContent] {
        let endpoint: String
        
        switch contentType {
        case .movie:
            endpoint = "movie/\(contentId)/recommendations"
        case .tvShow:
            endpoint = "tv/\(contentId)/recommendations"
        }
        
        let url = "\(baseURL)/\(endpoint)?api_key=\(apiKey)"
        
        guard let requestURL = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        do {
            let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
            return response.results
        } catch {
            print("Recommended content decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
   
    func fetchWatchProviders(for contentId: Int, contentType: TMDBContentType) async throws -> WatchProviders? {
        let typeString = contentType == .movie ? "movie" : "tv"
        let urlString = "\(baseURL)/\(typeString)/\(contentId)/watch/providers?api_key=\(apiKey)"
        
        print("🔍 Fetching watch providers from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ Watch providers API error: \(response)")
            throw TMDBError.invalidResponse
        }
        
        do {
            let watchResponse = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)
            let usProviders = watchResponse.results?["US"]
            
            print("📺 Found providers for US:")
            print("   Subscription: \(usProviders?.flatrate?.map { $0.providerName } ?? [])")
            print("   Rental: \(usProviders?.rent?.map { $0.providerName } ?? [])")
            print("   Purchase: \(usProviders?.buy?.map { $0.providerName } ?? [])")
            
            return usProviders
        } catch {
            print("❌ Watch providers decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // Add this to TMDBService.swift in the "MARK: - API Methods" section
    func fetchContentById(_ id: Int, type: String) async throws -> TMDBContent {
        if type == "movie_watchlist" {
            return try await fetchMovieById(id)
        } else {
            return try await fetchTVShowById(id)
        }
    }


    private func fetchMovieById(_ id: Int) async throws -> TMDBContent {
        let urlString = "\(baseURL)/movie/\(id)?api_key=\(apiKey)"
        
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
            // Decode as a single movie (not an array)
            let movieData = try JSONDecoder().decode(MovieSingleResponse.self, from: data)
            return movieData.toTMDBContent()
        } catch {
            print("Movie by ID decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }

    private func fetchTVShowById(_ id: Int) async throws -> TMDBContent {
        let urlString = "\(baseURL)/tv/\(id)?api_key=\(apiKey)"
        
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
            // Decode as a single TV show (not an array)
            let tvData = try JSONDecoder().decode(TVShowSingleResponse.self, from: data)
            return tvData.toTMDBContent()
        } catch {
            print("TV show by ID decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
}

extension TMDBService {
    
    // IMPROVED: Proper actor search using TMDB person API
    func searchActorSimple(_ actorName: String) async throws -> [TMDBContent] {
        print("🎭 Searching for actor movies: \(actorName)")
        
        // Step 1: Search for the person to get their ID
        let personId = try await searchPersonId(actorName)
        
        if let personId = personId {
            // Step 2: Get their movie credits using person ID
            print("✅ Found person ID: \(personId), fetching credits...")
            return try await fetchPersonMovieCredits(personId)
        } else {
            // Fallback: Use improved keyword search
            print("⚠️ Person not found, using keyword search fallback")
            return try await searchActorKeywordFallback(actorName)
        }
    }
    
    // Step 1: Find the person's TMDB ID
    private func searchPersonId(_ actorName: String) async throws -> Int? {
        let encodedName = actorName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search/person?api_key=\(apiKey)&query=\(encodedName)"
        
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
            let personResponse = try JSONDecoder().decode(PersonSearchResponse.self, from: data)
            // Return the most popular person with this name
            let topResult = personResponse.results
                .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
                .first
            
            print("🔍 Person search results: \(personResponse.results.map { $0.name })")
            return topResult?.id
        } catch {
            print("❌ Person search decoding error: \(error)")
            return nil
        }
    }
    
    // Step 2: Get actor's movie credits
    private func fetchPersonMovieCredits(_ personId: Int) async throws -> [TMDBContent] {
        let urlString = "\(baseURL)/person/\(personId)/movie_credits?api_key=\(apiKey)"
        
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
            let creditsResponse = try JSONDecoder().decode(PersonCreditsResponse.self, from: data)
            
            // Convert credits to TMDBContent and filter for quality
            let movieCredits = creditsResponse.cast
                .filter { credit in
                    // Filter for main roles and good movies
                    let hasGoodRating = (credit.voteAverage ?? 0) > 5.5
                    let isMainRole = (credit.order ?? 999) < 10 // Top 10 billing
                    let hasVotes = (credit.voteCount ?? 0) > 100 // Popular enough
                    
                    return hasGoodRating && isMainRole && hasVotes
                }
                .sorted { credit1, credit2 in
                    // Sort by popularity (vote count) and rating
                    let score1 = (credit1.voteAverage ?? 0) * Double(credit1.voteCount ?? 0)
                    let score2 = (credit2.voteAverage ?? 0) * Double(credit2.voteCount ?? 0)
                    return score1 > score2
                }
                .prefix(8) // Limit to top 8 movies
                .map { credit in
                    // Convert to TMDBContent
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
                        mediaType: "movie",
                        voteCount: credit.voteCount
                    )
                }
            
            print("🎬 Found \(movieCredits.count) quality movies for actor")
            print("🎬 Top movies: \(movieCredits.prefix(3).map { $0.displayTitle })")
            
            return Array(movieCredits)
            
        } catch {
            print("❌ Credits decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    // Fallback: Improved keyword search that filters out documentaries
    private func searchActorKeywordFallback(_ actorName: String) async throws -> [TMDBContent] {
        // Try multiple search strategies
        let searchQueries = [
            "\(actorName) movie",
            actorName,
            "\(actorName) film"
        ]
        
        for query in searchQueries {
            let results = try await search(query)
            let filtered = results.filter { content in
                let title = content.displayTitle.lowercased()
                let overview = content.overview?.lowercased() ?? ""
                
                // Filter OUT documentaries and biography content
                let isDocumentary = title.contains("documentary") ||
                                  title.contains("biography") ||
                                  title.contains("behind the scenes") ||
                                  title.contains("making of") ||
                                  title.contains("interview") ||
                                  overview.contains("documentary about") ||
                                  overview.contains("biography of")
                
                // Filter FOR good movies/shows
                let hasGoodRating = (content.voteAverage ?? 0) > 5.0
                let isActualMovie = content.isMovie || content.isTVShow
                
                return !isDocumentary && hasGoodRating && isActualMovie
            }
            .sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
            
            if filtered.count >= 3 {
                print("✅ Keyword search '\(query)' found \(filtered.count) filtered results")
                return Array(filtered.prefix(6))
            }
        }
        
        print("⚠️ All keyword searches failed, returning empty results")
        return []
    }
}

// MARK: - Person Search Response Models
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
    let order: Int? // Lower order = more important role
    let voteCount: Int? // Popularity indicator
    
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

struct WatchProvidersResponse: Codable {
    let results: [String: WatchProviders]?
}


struct WatchProviders: Codable {
    let link: String?
    let flatrate: [WatchProvider]? // Subscription services
    let rent: [WatchProvider]?     // Rental options
    let buy: [WatchProvider]?      // Purchase options
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

// Add these after your existing response models

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
    
    func toTMDBContent() -> TMDBService.TMDBContent {
        return TMDBService.TMDBContent(
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
    
    func toTMDBContent() -> TMDBService.TMDBContent {
        return TMDBService.TMDBContent(
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
