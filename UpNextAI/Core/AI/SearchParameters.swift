//
//  SearchParameters.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/29/25.
//

import Foundation

struct SearchParameters: CustomStringConvertible {
    var genres: [String] = []
    var country: String?
    var yearRange: ClosedRange<Int>?
    var contentType: ContentType?
    var similarToTitle: String?
    var actorName: String? // NEW: For actor searches
    var keywords: [String] = []
    
    // NEW: Added missing properties for enhanced functionality
    var directorName: String?      // For director searches
    var franchiseName: String?     // For franchise searches (Marvel, Star Wars, etc.)
    var mood: String?              // For mood-based searches (dark, feel-good, etc.)
    
    // MARK: - Debug Description
    var description: String {
        var parts: [String] = []
        
        if !genres.isEmpty {
            parts.append("genres: \(genres)")
        }
        if let country = country {
            parts.append("country: \(country)")
        }
        if let contentType = contentType {
            parts.append("type: \(contentType.rawValue)")
        }
        if let title = similarToTitle {
            parts.append("similar to: '\(title)'")
        }
        if let actor = actorName {
            parts.append("actor: '\(actor)'")
        }
        if let director = directorName {
            parts.append("director: '\(director)'")
        }
        if let franchise = franchiseName {
            parts.append("franchise: '\(franchise)'")
        }
        if let mood = mood {
            parts.append("mood: '\(mood)'")
        }
        if let yearRange = yearRange {
            parts.append("years: \(yearRange.lowerBound)-\(yearRange.upperBound)")
        }
        if !keywords.isEmpty {
            parts.append("keywords: \(keywords)")
        }
        
        return parts.joined(separator: ", ")
    }
    
    // MARK: - TMDB Integration Methods
    
    /// Maps AI analysis to your existing TMDB service endpoints
    func suggestedTMDBEndpoint() -> String? {
        // Prioritize country-specific endpoints (matches your existing specialty endpoints)
        if let country = country {
            switch country {
            case "KR":
                return "kdramas"
            case "GB":
                return "britishTVShows"
            case "IN":
                return "bollywoodMovies"
            case "ES":
                return "telenovelas"
            default:
                break
            }
        }
        
        // Use genre-specific endpoints (works with your existing fetchByGenre method)
        if let primaryGenre = genres.first {
            return primaryGenre.lowercased() // Maps to your TMDBService.fetchByGenre()
        }
        
        return nil // Use general search with keywords
    }
    
    /// Creates search query string for your existing TMDB search method
    func toSearchQuery() -> String {
        var queryParts: [String] = []
        
        // Prioritize actor searches
        if let actor = actorName {
            queryParts.append(actor)
        }
        
        // Prioritize director searches
        if let director = directorName {
            queryParts.append(director)
        }
        
        // Prioritize franchise searches
        if let franchise = franchiseName {
            queryParts.append(franchise)
        }
        
        // Prioritize similar title searches
        if let title = similarToTitle {
            queryParts.append(title)
        }
        
        // Add genre context
        queryParts.append(contentsOf: genres)
        
        // Add relevant keywords (limit to avoid too broad searches)
        queryParts.append(contentsOf: keywords.prefix(3))
        
        return queryParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Determines the best search strategy for your existing TMDB integration
    var searchStrategy: SearchStrategy {
        // NEW: If we have an actor, use actor search
        if actorName != nil {
            return .actorSearch
        }
        
        // NEW: If we have a director, use keyword search (since no specific director endpoint)
        if directorName != nil {
            return .keywordSearch
        }
        
        // NEW: If we have a franchise, use keyword search
        if franchiseName != nil {
            return .keywordSearch
        }
        
        // If we have a specific title reference, use search
        if similarToTitle != nil {
            return .titleSearch
        }
        
        // If we have country or genre specifics, use endpoint
        if country != nil || !genres.isEmpty {
            return .endpointSearch
        }
        
        // Fall back to keyword search
        if !keywords.isEmpty {
            return .keywordSearch
        }
        
        // Default to trending/popular
        return .fallback
    }
    
    /// Validates that we have enough information to perform a meaningful search
    var isValidForSearch: Bool {
        return !genres.isEmpty ||
               country != nil ||
               similarToTitle != nil ||
               actorName != nil ||
               directorName != nil ||
               franchiseName != nil ||
               !keywords.isEmpty
    }
    
    /// Returns user-friendly description of what we're searching for
    var searchDescription: String {
        var parts: [String] = []
        
        if let actor = actorName {
            parts.append("movies with \(actor)")
        }
        
        if let director = directorName {
            parts.append("movies by \(director)")
        }
        
        if let franchise = franchiseName {
            parts.append("\(franchise) movies")
        }
        
        if let title = similarToTitle {
            parts.append("content similar to \(title)")
        }
        
        if !genres.isEmpty {
            if genres.count == 2 && genres.contains("Romance") && genres.contains("Comedy") {
                parts.append("romantic comedies")
            } else {
                parts.append("\(genres.joined(separator: ", ")) content")
            }
        }
        
        if let mood = mood {
            parts.append("(\(mood) mood)")
        }
        
        if let country = country {
            let countryName = countryDisplayName(for: country)
            parts.append("from \(countryName)")
        }
        
        if let contentType = contentType {
            parts.append("(\(contentType.rawValue)s)")
        }
        
        if let yearRange = yearRange {
            if yearRange.lowerBound == yearRange.upperBound {
                parts.append("from \(yearRange.lowerBound)")
            } else {
                parts.append("from \(yearRange.lowerBound)-\(yearRange.upperBound)")
            }
        }
        
        if parts.isEmpty {
            return "content matching your query"
        }
        
        return parts.joined(separator: " ")
    }
    
    // MARK: - Helper Methods
    
    private func countryDisplayName(for countryCode: String) -> String {
        switch countryCode {
        case "KR": return "Korea"
        case "GB": return "the UK"
        case "IN": return "India"
        case "ES": return "Spain"
        case "JP": return "Japan"
        default: return countryCode
        }
    }
}

// MARK: - Search Strategy Enum
enum SearchStrategy {
    case actorSearch      // NEW: Search by actor name
    case titleSearch      // Use TMDB search with title
    case endpointSearch   // Use specific TMDB endpoint (genre/country)
    case keywordSearch    // Use TMDB search with keywords
    case fallback         // Use trending/popular content
    
    var description: String {
        switch self {
        case .actorSearch: return "Searching by actor"
        case .titleSearch: return "Searching for similar titles"
        case .endpointSearch: return "Searching by category"
        case .keywordSearch: return "Searching by keywords"
        case .fallback: return "Showing popular content"
        }
    }
}
