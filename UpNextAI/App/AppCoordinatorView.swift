//
//  AppCoordinatorView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//

import SwiftUI

struct AppCoordinatorView: View {
    @StateObject private var appCoordinator: AppCoordinator
    
    init() {
        // Initialize your repositories here
        let userRepository = UserPreferenceRepository() // Use your real initializer
        let contentRepository = ContentRepository() // Use your real initializer
        
        self._appCoordinator = StateObject(wrappedValue: AppCoordinator(
            userRepository: userRepository,
            contentRepository: contentRepository
        ))
    }
    
    var body: some View {
        Group {
            switch appCoordinator.currentFlow {
            case .loading:
                LoadingView()
                
            case .onboarding:
                if let onboardingCoordinator = appCoordinator.onboardingCoordinator {
                    OnboardingContainerView(coordinator: onboardingCoordinator)
                }
                
            case .mainApp:
                if let tabCoordinator = appCoordinator.tabCoordinator {
                    tabCoordinator.createTabView()
                } else {
                    Text("Loading...")
                }
            }
        }
        .onAppear {
            Task {
                await appCoordinator.start()
            }
        }
    }
}

// Simple loading view
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .padding(.top)
        }
    }
}

// Placeholder for main app
struct MainAppView: View {
    var body: some View {
        ContentFeedView()
    }
}
