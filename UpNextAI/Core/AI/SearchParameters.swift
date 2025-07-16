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
    var actorName: String?
    var keywords: [String] = []
    var directorName: String?
    var franchiseName: String?
    var mood: String?
    
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
    
    // MARK: - ✅ UPDATED: Maps to new coordinator-based architecture
    func suggestedSearchMethod() -> String? {
        // Handle mood-to-genre conversion
        var effectiveGenres = genres
        if let mood = mood, effectiveGenres.isEmpty {
            switch mood {
            case "feel-good", "light":
                effectiveGenres = ["Comedy"]
            case "dark":
                effectiveGenres = ["Crime", "Thriller"]
            case "intense":
                effectiveGenres = ["Action", "Thriller"]
            case "emotional":
                effectiveGenres = ["Drama"]
            case "smart":
                effectiveGenres = ["Drama", "Thriller"]
            default:
                break
            }
        }
        
        // ✅ UPDATED: Return specific method names for coordinator
        if let country = country {
            switch country {
            case "KR", "korean":
                return "fetchKDramas"
            case "GB", "british":
                return "fetchBritishTVShows"
            case "IN", "indian":
                return "fetchBollywoodMovies"
            case "ES", "spanish":
                return "fetchTelenovelas"
            default:
                break
            }
        }
        
        return nil
    }
    
    func toSearchQuery() -> String {
        var queryParts: [String] = []
        
        // Prioritize specific searches
        if let actor = actorName {
            queryParts.append(actor)
            return queryParts.joined(separator: " ")
        }
        
        if let director = directorName {
            queryParts.append(director)
            return queryParts.joined(separator: " ")
        }
        
        if let franchise = franchiseName {
            queryParts.append(franchise)
            return queryParts.joined(separator: " ")
        }
        
        if let title = similarToTitle {
            queryParts.append(title)
            return queryParts.joined(separator: " ")
        }
        
        // Handle year + genre combinations
        if let yearRange = yearRange, !genres.isEmpty {
            let yearString = yearRange.lowerBound == yearRange.upperBound ?
                "\(yearRange.lowerBound)" : "\(yearRange.lowerBound)s"
            
            queryParts.append(yearString)
            queryParts.append(contentsOf: genres.map { $0.lowercased() })
            
            return queryParts.joined(separator: " ")
        }
        
        // Add genre context
        queryParts.append(contentsOf: genres)
        
        // Add relevant keywords (limit to avoid too broad searches)
        queryParts.append(contentsOf: keywords.prefix(3))
        
        return queryParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // ✅ UPDATED: Enhanced search strategy for new architecture
    var searchStrategy: SearchStrategy {
        if actorName != nil {
            return .actorSearch
        }
        
        if directorName != nil {
            return .keywordSearch
        }
        
        if franchiseName != nil {
            return .keywordSearch
        }
        
        if let title = similarToTitle, !title.isEmpty {
            return .titleSearch
        }
        
        // ✅ NEW: Enhanced content type awareness
        if yearRange != nil && !genres.isEmpty {
            return .endpointSearch
        }
        
        if mood != nil && genres.isEmpty {
            return .endpointSearch
        }
        
        if country != nil || !genres.isEmpty {
            return .endpointSearch
        }
        
        if !keywords.isEmpty {
            return .keywordSearch
        }
        
        return .fallback
    }
    
    var isValidForSearch: Bool {
        return !genres.isEmpty ||
               country != nil ||
               similarToTitle != nil ||
               actorName != nil ||
               directorName != nil ||
               franchiseName != nil ||
               !keywords.isEmpty ||
               mood != nil
    }
    
    // ✅ UPDATED: Better search descriptions with content type awareness
    var searchDescription: String {
        var parts: [String] = []
        
        if let actor = actorName {
            let typeDescription = contentType == .tvShow ? "TV shows" :
                                 contentType == .movie ? "movies" : "content"
            parts.append("\(typeDescription) with \(actor)")
        }
        
        if let director = directorName {
            let typeDescription = contentType == .tvShow ? "TV shows" :
                                 contentType == .movie ? "movies" : "content"
            parts.append("\(typeDescription) by \(director)")
        }
        
        if let franchise = franchiseName {
            let typeDescription = contentType == .tvShow ? "TV shows" :
                                 contentType == .movie ? "movies" : "content"
            parts.append("\(franchise) \(typeDescription)")
        }
        
        if let title = similarToTitle {
            parts.append("content similar to \(title)")
        }
        
        if let yearRange = yearRange {
            let yearStr = yearRange.lowerBound == yearRange.upperBound ?
                "\(yearRange.lowerBound)" : "\(yearRange.lowerBound)s"
            
            if !genres.isEmpty {
                if genres.count == 2 && genres.contains("Romance") && genres.contains("Comedy") {
                    parts.append("\(yearStr) romantic comedies")
                } else {
                    parts.append("\(yearStr) \(genres.joined(separator: ", ").lowercased()) content")
                }
            } else {
                parts.append("content from the \(yearStr)")
            }
        } else if !genres.isEmpty {
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
        
        // ✅ NEW: Add content type to description
        if let contentType = contentType {
            if parts.isEmpty {
                parts.append("\(contentType.rawValue)s")
            } else {
                parts.append("(\(contentType.rawValue)s only)")
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

    }


// MARK: - Search Strategy Enum
enum SearchStrategy {
    case actorSearch
    case titleSearch
    case endpointSearch
    case keywordSearch
    case fallback
    
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
