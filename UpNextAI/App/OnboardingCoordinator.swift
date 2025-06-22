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
    
    func saveGenres(_ genres: [String]) {
        // TODO: Save genres to Core Data
        print("Saving genres: \(genres)")
        currentStep = .filmSelection
    }
    
    func saveMoviePreferences(_ movies: [String]) {
        // TODO: Save movie preferences
        print("Saving movies: \(movies)")
        currentStep = .tvSelection
    }
    
    func saveTVPreferences(_ shows: [String]) async throws {
        // TODO: Save TV preferences
        print("Saving TV shows: \(shows)")
        try await finishOnboarding()
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
