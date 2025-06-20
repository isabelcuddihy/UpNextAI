
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
    case trending
    case popular
    case topRated
    case genre(Int, String) // genre ID and name
    case upcoming
    case nowPlaying
    
    var displayTitle: String {
        switch self {
        case .trending:
            return "Trending Now"
        case .popular:
            return "Popular"
        case .topRated:
            return "Critically Acclaimed"
        case .genre(_, let name):
            return name
        case .upcoming:
            return "Coming Soon"
        case .nowPlaying:
            return "In Theaters"
        }
    }
}
