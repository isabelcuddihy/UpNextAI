//
//  UserPreferenceRepository.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//

import Foundation
import CoreData

protocol UserPreferenceRepositoryProtocol {
    func createUserProfile(name: String) async throws -> UserProfileCoreData
    func getUserProfile() async throws -> UserProfileCoreData?
    func addPreference(to profile: UserProfileCoreData, type: String, name: String, tmdbId: Int64?, isLiked: Bool) async throws
    func getPreferences(for profile: UserProfileCoreData, type: String?) async throws -> [UserPreferenceCoreData]
    func togglePreference(for profile: UserProfileCoreData, type: String, name: String, tmdbId: Int64?) async throws
    func deletePreference(_ preference: UserPreferenceCoreData) async throws
    func hasPreference(for profile: UserProfileCoreData, type: String, name: String) async throws -> UserPreferenceCoreData?
    func markOnboardingComplete(for profile: UserProfileCoreData) async throws
    
}

class UserPreferenceRepository: UserPreferenceRepositoryProtocol {
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - User Profile Management
    
    func createUserProfile(name: String) async throws -> UserProfileCoreData {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let profile = UserProfileCoreData(context: context)
            profile.id = UUID()
            profile.name = name
            profile.createdDate = Date()
            profile.lastUpdated = Date()
            profile.hasCompletedOnboarding = false
            
            try context.save()
            return profile
        }
    }
    
    func getUserProfile() async throws -> UserProfileCoreData? {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<UserProfileCoreData> = UserProfileCoreData.fetchRequest()
            request.fetchLimit = 1
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserProfileCoreData.createdDate, ascending: false)]
            
            return try context.fetch(request).first
        }
    }
    
    // MARK: - Preference Management
    
    func addPreference(to profile: UserProfileCoreData, type: String, name: String, tmdbId: Int64?, isLiked: Bool) async throws {
        let context = coreDataStack.mainContext
        
        try await context.perform {
            // Always fetch the profile fresh from the database
            let profileRequest: NSFetchRequest<UserProfileCoreData> = UserProfileCoreData.fetchRequest()
            profileRequest.predicate = NSPredicate(format: "id == %@", profile.id as CVarArg)
            profileRequest.fetchLimit = 1
            
            guard let profileInContext = try context.fetch(profileRequest).first else {
                throw NSError(domain: "ProfileNotFound", code: 404, userInfo: nil)
            }
            
            // Check if preference already exists
            let existingPreference = try self.findPreference(in: context, profile: profileInContext, type: type, name: name, tmdbId: tmdbId)
            
            if let existing = existingPreference {
                existing.isLiked = isLiked
                print("📝 Updated existing preference: \(name)")
            } else {
                // Create new preference
                let preference = UserPreferenceCoreData(context: context)
                preference.type = type
                preference.name = name
                preference.tmdbId = tmdbId ?? 0
                preference.isLiked = isLiked
                preference.createdAt = Date()
                preference.profile = profileInContext
                print("✅ Created new preference: \(name) (\(type))")
            }
            
            profileInContext.lastUpdated = Date()
            
            // Save and verify
            try context.save()
            
            // Verify the save worked
            let verifyRequest: NSFetchRequest<UserPreferenceCoreData> = UserPreferenceCoreData.fetchRequest()
            verifyRequest.predicate = NSPredicate(format: "profile == %@", profileInContext)
            let allPrefs = try context.fetch(verifyRequest)
            print("🔍 Total preferences after save: \(allPrefs.count)")
        }
    }
    
    func getPreferences(for profile: UserProfileCoreData, type: String? = nil) async throws -> [UserPreferenceCoreData] {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            // Always fetch the profile fresh
            let profileRequest: NSFetchRequest<UserProfileCoreData> = UserProfileCoreData.fetchRequest()
            profileRequest.predicate = NSPredicate(format: "id == %@", profile.id as CVarArg)
            profileRequest.fetchLimit = 1
            
            guard let profileInContext = try context.fetch(profileRequest).first else {
                return []
            }
            
            let request: NSFetchRequest<UserPreferenceCoreData> = UserPreferenceCoreData.fetchRequest()
            
            var predicates: [NSPredicate] = [NSPredicate(format: "profile == %@", profileInContext)]
            
            if let type = type {
                predicates.append(NSPredicate(format: "type == %@", type))
            }
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserPreferenceCoreData.createdAt, ascending: false)]
            
            let results = try context.fetch(request)
            print("🔍 Repository found \(results.count) preferences of type: \(type ?? "all")")
            
            return results
        }
    }
    
    func togglePreference(for profile: UserProfileCoreData, type: String, name: String, tmdbId: Int64?) async throws {
        let context = coreDataStack.mainContext
        
        try await context.perform {
            if let existing = try self.findPreference(in: context, profile: profile, type: type, name: name, tmdbId: tmdbId) {
                // Toggle existing preference
                existing.isLiked.toggle()
            } else {
                // Create new preference as liked
                let preference = UserPreferenceCoreData(context: context)
                preference.type = type
                preference.name = name
                preference.tmdbId = tmdbId ?? 0
                preference.isLiked = true
                preference.createdAt = Date()
                preference.profile = profile
            }
            
            profile.lastUpdated = Date()
            try context.save()
        }
    }
    
    func deletePreference(_ preference: UserPreferenceCoreData) async throws {
        let context = coreDataStack.mainContext
        
        try await context.perform {
            context.delete(preference)
            try context.save()
        }
    }
    
    func hasPreference(for profile: UserProfileCoreData, type: String, name: String) async throws -> UserPreferenceCoreData? {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            return try self.findPreference(in: context, profile: profile, type: type, name: name, tmdbId: nil)
        }
    }
    func markOnboardingComplete(for profile: UserProfileCoreData) async throws {
        let context = coreDataStack.mainContext
        try await context.perform {
            profile.hasCompletedOnboarding = true
            try context.save()
        }
    }
    
    // MARK: - Helper Methods
    
    private func findPreference(in context: NSManagedObjectContext, profile: UserProfileCoreData, type: String, name: String, tmdbId: Int64?) throws -> UserPreferenceCoreData? {
        let request: NSFetchRequest<UserPreferenceCoreData> = UserPreferenceCoreData.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "profile == %@", profile),
            NSPredicate(format: "type == %@", type),
            NSPredicate(format: "name == %@", name)
        ]
        
        if let tmdbId = tmdbId {
            predicates.append(NSPredicate(format: "tmdbId == %lld", tmdbId))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
}

// MARK: - Convenience Extensions

extension UserPreferenceRepository {
    
    // Genre-specific methods
    func addGenrePreference(to profile: UserProfileCoreData, genre: String, isLiked: Bool) async throws {
        try await addPreference(to: profile, type: "genre", name: genre, tmdbId: nil, isLiked: isLiked)
    }
    
    func getLikedGenres(for profile: UserProfileCoreData) async throws -> [String] {
        let preferences = try await getPreferences(for: profile, type: "genre")
        return preferences.filter { $0.isLiked }.map { $0.name ?? "" }
    }
    
    func getDislikedGenres(for profile: UserProfileCoreData) async throws -> [String] {
        let preferences = try await getPreferences(for: profile, type: "genre")
        return preferences.filter { !$0.isLiked }.map { $0.name ?? "" }
    }
    
    // Movie/Show specific methods
    func addContentPreference(to profile: UserProfileCoreData, contentType: String, name: String, tmdbId: Int64, isLiked: Bool) async throws {
        try await addPreference(to: profile, type: contentType, name: name, tmdbId: tmdbId, isLiked: isLiked)
    }
    
    func isContentLiked(for profile: UserProfileCoreData, contentType: String, tmdbId: Int64) async throws -> Bool? {
        let context = coreDataStack.mainContext
        
        return try await context.perform {
            let request: NSFetchRequest<UserPreferenceCoreData> = UserPreferenceCoreData.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "profile == %@", profile),
                NSPredicate(format: "type == %@", contentType),
                NSPredicate(format: "tmdbId == %lld", tmdbId)
            ])
            request.fetchLimit = 1
            
            return try context.fetch(request).first?.isLiked
        }
    }
}
