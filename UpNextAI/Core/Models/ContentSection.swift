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
    let content: [TMDBService.TMDBContent]
    let category: ContentCategory
}

enum ContentCategory {
    // Mixed content
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
        // Mixed content
        case .trending:
            return "Trending Now"
        case .genre(_, let name):
            return name
            
        // Movie categories
        case .moviePopular:
            return "Popular Movies"
        case .movieTopRated:
            return "Top Rated Movies"
        case .movieUpcoming:
            return "Coming Soon"
        case .movieNowPlaying:
            return "In Theaters"
            
        // TV categories
        case .tvPopular:
            return "Popular TV Shows"
        case .tvTopRated:
            return "Top Rated TV Shows"
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
        case .moviePopular, .movieTopRated, .movieUpcoming, .movieNowPlaying:
            return .movie
        case .tvPopular, .tvTopRated, .tvAiringToday, .tvOnTheAir, .kdramas, .cdramas, .anime:
            return .tvShow
        case .trending, .genre:
            return .mixed
        }
    }
}
