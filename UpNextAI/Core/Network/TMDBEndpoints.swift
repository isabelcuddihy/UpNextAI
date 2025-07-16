import Foundation

// MARK: - TMDB Endpoints
enum TMDBEndpoint {
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
    case superheroMovies
    case historicalMovies
    case trueCrimeDocumentaries
    case bollywoodMovies
    case animeMovies
    case kidsAndFamilyMovies
    case sciFiMovies
    case thrillerMovies
    case adventureMovies
    case mysteryMovies
    
    // TV-specific endpoints
    case tvPopular
    case tvTopRated
    case tvAiringToday
    case tvOnTheAir
    case actionTVShows
    case comedyTVShows
    case dramaTVShows
    case crimeTV
    case kdramas
    case superheroTVShows
    case historicalTVShows
    case trueCrimeTVShows
    case britishTVShows
    case telenovelas
    case animeTVShows
    case kidsAndFamilyTVShows
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
            return "/discover/movie?api_key=\(apiKey)&with_genres=14"
        case .animationMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=16"
        case .superheroMovies:
            return "/discover/movie?api_key=\(apiKey)&with_keywords=superhero"
        case .historicalMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=36"
        case .trueCrimeDocumentaries:
            return "/discover/movie?api_key=\(apiKey)&with_genres=99&with_keywords=true-crime"
        case .bollywoodMovies:
            return "/discover/movie?api_key=\(apiKey)&with_origin_country=IN&with_original_language=hi"
        case .animeMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=16&with_origin_country=JP"
        case .kidsAndFamilyMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=10751"
        case .sciFiMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=878"
        case .thrillerMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=53"
        case .adventureMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=12"
        case .mysteryMovies:
            return "/discover/movie?api_key=\(apiKey)&with_genres=9648"
            
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
            return "/discover/tv?api_key=\(apiKey)&with_genres=10759"
        case .comedyTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=35"
        case .dramaTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=18"
        case .crimeTV:
            return "/discover/tv?api_key=\(apiKey)&with_genres=80"
        case .kdramas:
            return "/discover/tv?api_key=\(apiKey)&with_genres=18&with_origin_country=KR"
        case .superheroTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_keywords=superhero"
        case .historicalTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=36"
        case .trueCrimeTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=99&with_keywords=true-crime"
        case .britishTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_origin_country=GB"
        case .telenovelas:
            return "/discover/tv?api_key=\(apiKey)&with_original_language=es&with_genres=18"
        case .animeTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=16&with_origin_country=JP"
        case .kidsAndFamilyTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=10762"
        case .sciFiTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=10765"
        case .thrillerTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=9648"
        case .adventureTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=10759"
        case .mysteryTVShows:
            return "/discover/tv?api_key=\(apiKey)&with_genres=9648"
        }
    }
}
