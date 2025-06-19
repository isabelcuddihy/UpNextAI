//
//  UserProfile.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import Foundation

enum Interest: String, CaseIterable {
    case action = "Action"
    case comedy = "Comedy"
    case drama = "Drama"
    case horror = "Horror"
    case romance = "Romance"
    case sciFi = "Science Fiction"
    case thriller = "Thriller"
    case documentary = "Documentary"
    case animation = "Animation"
    case family = "Family"
    case fantasy = "Fantasy"
    case mystery = "Mystery"
}

struct UserProfile: Identifiable, Hashable {
    let id = UUID()
    let selectedInterests: [Interest]
    let createdDate: Date
    let lastUpdated: Date
    
    // AI learning data
    let contentInteractions: [String: Double]
    
    
    
    // Interests based on User's active interactions during onboarding
    // Example["Technology", "Sports", "Health"]
    var interestsJSON: String {
        let interestStrings = selectedInterests.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(interestStrings),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "[]"
    }

    
    // Helper for creating from Interests JSON
    static func fromInterestsJSON(_ json: String) -> [Interest] {
        guard let data = json.data(using: .utf8),
              let strings = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return strings.compactMap { Interest(rawValue: $0) }
    }
    
    // Interests for AI Learning, will grow as user continues to interact with app
    var contentInteractionsJSON: String {
        if let data = try? JSONEncoder().encode(contentInteractions),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{}"
    }
    
    // Helper for creating from Content Interaction KSON
    static func fromContentInteractionsJSON(_ json: String) -> [String: Double] {
        guard let data = json.data(using: .utf8),
              let interactions = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return [:]
        }
        return interactions
    }
}
