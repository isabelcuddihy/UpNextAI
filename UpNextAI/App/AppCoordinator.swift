//
//  AppCoordinator.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/16/25.
//

import SwiftUI

enum AppFlow {
    case loading
    case onboarding
    case mainApp
}

@MainActor
class AppCoordinator: ObservableObject {
    // MARK: - Published State
    @Published var currentFlow: AppFlow = .loading
    
    // MARK: - Dependencies
    private let userRepository: UserPreferenceRepository
    private let contentRepository: ContentRepository
    
    // MARK: - Child Coordinators
    var onboardingCoordinator: OnboardingCoordinator?
    var mainAppCoordinator: AppCoordinator?
    var tabCoordinator: TabCoordinator?
    
    // MARK: - Current User State
    private var currentUserProfile: UserProfileCoreData?
    
    // MARK: - Initialization
    init(userRepository: UserPreferenceRepository = UserPreferenceRepository(),
         contentRepository: ContentRepository = ContentRepository()) {
        self.userRepository = userRepository
        self.contentRepository = contentRepository
    }
    
    func start() async {
        currentFlow = .loading
        
        do {
            print("🔍 Starting AppCoordinator...")
            let profiles = try await userRepository.getUserProfile()
            print("✅ Successfully loaded profiles")
            
            if let existingProfile = profiles {
                currentUserProfile = existingProfile
                print("👤 Found existing profile: \(existingProfile.name)")
                
                if existingProfile.hasCompletedOnboarding {
                    print("🏠 User completed onboarding, going to main app")
                    showTabCoordinator()
                } else {
                    print("📝 User needs to complete onboarding")
                    showOnboarding()
                }
            } else {
                print("👋 New user, showing onboarding")
                showOnboarding()
            }
            
        } catch {
            print("❌ Core Data Error: \(error)")
            print("📱 Proceeding with onboarding anyway...")
            showOnboarding()
        }
    }
    
    // MARK: - Flow Management
    func showOnboarding() {
        onboardingCoordinator = OnboardingCoordinator(
            userRepository: userRepository,
            onCompletion: { [weak self] completedProfile in
                // This closure gets called when onboarding finishes
                self?.currentUserProfile = completedProfile
                self?.showTabCoordinator()
                self?.currentFlow = .mainApp
            }
        )
        
        currentFlow = .onboarding
        onboardingCoordinator?.start()
    }

    func showTabCoordinator() {
        tabCoordinator = TabCoordinator()
        currentFlow = .mainApp
    }

    func onboardingCompleted(userProfile: UserProfileCoreData) {
        currentUserProfile = userProfile
        // TODO: Update hasCompletedOnboarding to true
        showTabCoordinator()
    }
    
    // MARK: - User Profile Management
    private func checkForUserProfile() async throws -> UserProfileCoreData? {
        return try await userRepository.getUserProfile()
    }
}
