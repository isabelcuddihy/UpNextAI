//
//  OnboardingCoordinator.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//
import Foundation

@MainActor
class OnboardingCoordinator: ObservableObject {
    private let userRepository: UserPreferenceRepository
    private var currentProfile: UserProfileCoreData?
    private let onCompletion: (UserProfileCoreData) -> Void
    
    @Published var currentStep: OnboardingStep = .welcome
    
    enum OnboardingStep {
        case welcome
        case genreSelection
        case filmSelection
        case tvSelection
    }
    
    init(userRepository: UserPreferenceRepository,
         existingProfile: UserProfileCoreData? = nil,
         onCompletion: @escaping (UserProfileCoreData) -> Void) {
        self.userRepository = userRepository
        self.currentProfile = existingProfile
        self.onCompletion = onCompletion
    }
    
    func start() {
        currentStep = .welcome
    }
    
    func createProfile(name: String) async throws {
        currentProfile = try await userRepository.createUserProfile(name: name)
        currentStep = .genreSelection
    }
    
    func saveGenres(_ genres: [String]) async throws {
        guard let profile = currentProfile else {
            throw OnboardingError.noProfileCreated
        }
        
        print("💾 Saving \(genres.count) genres to Core Data...")
        
        for genre in genres {
            try await userRepository.addGenrePreference(to: profile, genre: genre, isLiked: true)
        }
        
        // Force a context save and refresh
        try await refreshProfile()
        
        print("✅ Saved genres: \(genres)")
        currentStep = .filmSelection
    }

    func saveMoviePreferences(_ movies: [String]) async throws {
        guard let profile = currentProfile else {
            throw OnboardingError.noProfileCreated
        }
        
        print("💾 Saving \(movies.count) movie preferences to Core Data...")
        
        for movie in movies {
            try await userRepository.addPreference(to: profile, type: "movie", name: movie, tmdbId: nil, isLiked: true)
        }
        
        try await refreshProfile()
        
        print("✅ Saved movie preferences: \(movies)")
        currentStep = .tvSelection
    }
    
    func saveTVPreferences(_ shows: [String]) async throws {
        guard let profile = currentProfile else {
            throw OnboardingError.noProfileCreated
        }
        
        print("💾 Saving \(shows.count) TV show preferences to Core Data...")
        
        // Save each TV show preference
        for show in shows {
            try await userRepository.addPreference(to: profile, type: "show", name: show, tmdbId: nil, isLiked: true)
        }
        
        
        print("✅ Saved TV show preferences: \(shows)")
        try await finishOnboarding()
    }

    // Add this helper method
    private func refreshProfile() async throws {
        if let profile = currentProfile {
            // Refresh the profile to see latest changes
            let context = userRepository.coreDataStack.mainContext
            await context.perform {
                context.refresh(profile, mergeChanges: true)
            }
        }
    }
    private func finishOnboarding() async throws {
        guard let profile = currentProfile else {
            throw OnboardingError.noProfileCreated
        }
        
        try await userRepository.markOnboardingComplete(for: profile)
        onCompletion(profile)
    }
}

enum OnboardingError: Error {
    case noProfileCreated
}
