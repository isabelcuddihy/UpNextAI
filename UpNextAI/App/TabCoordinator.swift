//
//  TabCoordinator.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/24/25.
//

import SwiftUI
import Combine

class TabCoordinator {
    private let userPreferenceRepository: UserPreferenceRepository
    private let contentRepository: ContentRepository
    private let tabCommunicationService: TabCommunicationService
    
    init(userPreferenceRepository: UserPreferenceRepository = UserPreferenceRepository(),
         contentRepository: ContentRepository = ContentRepository(),
         tabCommunicationService: TabCommunicationService = TabCommunicationService()) {
        self.userPreferenceRepository = userPreferenceRepository
        self.contentRepository = contentRepository
        self.tabCommunicationService = tabCommunicationService
    }
    
    @MainActor
    func createTabView() -> some View {
        // Create ViewModels with shared dependencies
        let contentViewModel = ContentViewModel(userRepository: userPreferenceRepository, tabCommunicationService: tabCommunicationService)
        let chatViewModel = ChatViewModel(
            userRepository: userPreferenceRepository,
            contentRepository: contentRepository,
            communicationService: tabCommunicationService
        )
        let profileViewModel = ProfileViewModel(
            userRepository: userPreferenceRepository,
            contentRepository: contentRepository, 
            communicationService: tabCommunicationService
        )
        
        return TabView {
            // Discover Tab - Your existing content feed
            ContentFeedView()
                .environmentObject(contentViewModel)
                .environmentObject(userPreferenceRepository)
                .environmentObject(contentRepository)
                .environmentObject(tabCommunicationService)
                .tabItem {
                    Image(systemName: "tv")
                    Text("Discover")
                }
            
            // Chat Tab - AI-powered recommendations
            ChatView()
                .environmentObject(chatViewModel)
                .environmentObject(userPreferenceRepository)
                .environmentObject(contentRepository)
                .environmentObject(tabCommunicationService)
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
            
            // Profile Tab - Watchlist and user preferences
            ProfileView()
                .environmentObject(profileViewModel)
                .environmentObject(userPreferenceRepository)
                .environmentObject(contentRepository)        // Now this works too
                .environmentObject(tabCommunicationService)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .tint(.blue) // Tab selection color
    }
}



// MARK: - Tab Communication Service
// Could be moved into a new file, keeping here for now for clarity

class TabCommunicationService: ObservableObject {
    @Published var watchlistUpdated: Bool = false
    @Published var newWatchlistItem: Content?
    @Published var genresUpdated: Bool = false
    
    func notifyWatchlistUpdate(_ content: Content) {
        newWatchlistItem = content
        watchlistUpdated.toggle()
    }

    func notifyGenreUpdate() {
        genresUpdated.toggle()
        print("📢 Notified tabs of genre update")
    }
}
