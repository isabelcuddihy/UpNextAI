//
//  ContentSection.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import Foundation

struct ContentSection: Identifiable {
    let id = UUID()
    let title: String
    let content: [TMDBContent]
    let category: ContentCategory
}

enum ContentCategory {
    // NEW: Personalized content categories
    case recommended
    case watchlist
    case genreBased(String) // Genre name from user preferences
    
    // Mixed content (keeping for backwards compatibility)
    case trending
    case genre(Int, String) // genre ID and name
    
    // Movie-specific categories
    case moviePopular
    case movieTopRated
    case movieUpcoming
    case movieNowPlaying
    
    // TV show-specific categories
    case tvPopular
    case tvTopRated
    case tvAiringToday
    case tvOnTheAir
    
    // Special categories
    case kdramas
    case cdramas
    case anime
    
    var displayTitle: String {
        switch self {
        // NEW: Personalized categories
        case .recommended:
            return "Recommended for You"
        case .watchlist:
            return "Your Watchlist"
        case .genreBased(let genreName):
            return "More \(genreName.capitalized)"
            
        // Mixed content
        case .trending:
            return "Trending Now"
        case .genre(_, let name):
            return name
            
        // Movie categories
        case .moviePopular:
            return "Popular Movies"
        case .movieTopRated:
            return "Critically Acclaimed Movies" // Updated for better UX
        case .movieUpcoming:
            return "Coming Soon"
        case .movieNowPlaying:
            return "In Theaters"
            
        // TV categories
        case .tvPopular:
            return "Popular TV Shows"
        case .tvTopRated:
            return "Must-Watch TV Shows" // Updated for better UX
        case .tvAiringToday:
            return "Airing Today"
        case .tvOnTheAir:
            return "On The Air"
            
        // Special categories
        case .kdramas:
            return "K-Dramas"
        case .cdramas:
            return "C-Dramas"
        case .anime:
            return "Anime"
        }
    }
    
    var contentType: ContentType {
        switch self {
        // Personalized categories are mixed content
        case .recommended, .watchlist, .genreBased:
            return .mixed
            
        case .moviePopular, .movieTopRated, .movieUpcoming, .movieNowPlaying:
            return .movie
        case .tvPopular, .tvTopRated, .tvAiringToday, .tvOnTheAir, .kdramas, .cdramas, .anime:
            return .tvShow
        case .trending, .genre:
            return .mixed
        }
    }
    
    // NEW: Helper to identify ML-relevant categories
    var isPersonalized: Bool {
        switch self {
        case .recommended, .watchlist, .genreBased:
            return true
        default:
            return false
        }
    }
    
    // NEW: Priority for ordering sections (lower = higher priority)
    var priority: Int {
        switch self {
        case .recommended: return 1      // Always first
        case .watchlist: return 2        // Second (if not empty)
        case .genreBased: return 3       // User's favorite genres
        case .movieTopRated, .tvTopRated: return 4  // High-quality content
        default: return 10               // Everything else
        }
    }
}


