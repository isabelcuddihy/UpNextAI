//
//  OnboardingCoordinatorView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//


import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var coordinator: OnboardingCoordinator
    
    init(coordinator: OnboardingCoordinator) {
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        switch coordinator.currentStep {
        case .welcome:
            WelcomeView { name in
                Task {
                    try await coordinator.createProfile(name: name)
                }
            }
            
        case .genreSelection:
            GenreSelectionView { genres in
                coordinator.saveGenres(genres)
            }
            
        case .filmSelection:
            OnboardingMovieSelectionView(coordinator: coordinator)  // Pass coordinator
            
        case .tvSelection:
            OnboardingTVSelectionView(coordinator: coordinator)     // Pass coordinator
        }
    }
}
