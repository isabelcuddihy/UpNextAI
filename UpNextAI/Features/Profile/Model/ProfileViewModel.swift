//
//  ProfileModel.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/28/25.
//

import Foundation
import Combine

// MARK: - Profile Components

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfileCoreData?
    @Published var watchlist: [Content] = []
    @Published var favoriteGenres: [String] = []
    @Published var isLoading = false
    
    private let userRepository: UserPreferenceRepository
    private let contentRepository: ContentRepository  // Add this
    private let communicationService: TabCommunicationService
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserPreferenceRepository,
         contentRepository: ContentRepository,  // Add this parameter
         communicationService: TabCommunicationService) {
        self.userRepository = userRepository
        self.contentRepository = contentRepository  // Add this
        self.communicationService = communicationService
        
        setupCommunication()
        loadUserData()
    }
    
    private func setupCommunication() {
        communicationService.$watchlistUpdated
            .sink { [weak self] _ in
                Task {
                    await self?.loadWatchlist()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadUserData() {
        Task {
            await loadUserProfile()
            await loadWatchlist()
            await loadFavoriteGenres()
        }
    }
    
    private func loadUserProfile() async {
        do {
            userProfile = try await userRepository.getUserProfile()
        } catch {
            print("Failed to load user profile: \(error)")
        }
    }
    
    private func loadWatchlist() async {
            guard let profile = userProfile else { return }
            
            do {
                isLoading = true
                
                // Get watchlist preferences from Core Data
                let movieWatchlist = try await userRepository.getPreferences(for: profile, type: "movie_watchlist")
                let tvWatchlist = try await userRepository.getPreferences(for: profile, type: "tv_watchlist")
                
                // Prepare the IDs and types for the repository
                var tmdbIds: [(id: Int, type: String)] = []
                
                for preference in movieWatchlist {
                    if preference.tmdbId > 0 {  // Check if it's a valid ID (Core Data might store 0 for "nil")
                        let convertedId = Int(preference.tmdbId)  // Convert Int64 to Int
                        tmdbIds.append((id: convertedId, type: "movie_watchlist"))
                    }
                }

                for preference in tvWatchlist {
                    if preference.tmdbId > 0 {  // Check if it's a valid ID
                        let convertedId = Int(preference.tmdbId)  // Convert Int64 to Int
                        tmdbIds.append((id: convertedId, type: "tv_watchlist"))
                    }
                }
                
                // Fetch the actual content using the repository
                let fetchedWatchlist = try await contentRepository.fetchWatchlistContent(tmdbIds: tmdbIds)
                
                await MainActor.run {
                    self.watchlist = fetchedWatchlist
                    self.isLoading = false
                }
                
            } catch {
                print("Failed to load watchlist: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }

    
    private func loadFavoriteGenres() async {
        guard let profile = userProfile else { return }
        
        do {
            let preferences = try await userRepository.getPreferences(for: profile, type: "genre")
            favoriteGenres = preferences
                .filter { $0.isLiked }
                .compactMap { $0.name }
        } catch {
            print("Failed to load favorite genres: \(error)")
        }
    }

    func updateGenres(_ newGenres: [String]) {
        Task {
            guard let profile = userProfile else { return }
            
            do {
                // Get all current genre preferences
                let currentPreferences = try await userRepository.getPreferences(for: profile, type: "genre")
                
                // Remove all current genre preferences
                for preference in currentPreferences {
                    try await userRepository.deletePreference(preference)
                }
                
                // Add new genre preferences
                for genre in newGenres {
                    try await userRepository.addGenrePreference(to: profile, genre: genre, isLiked: true)
                }
                
                // Update local state
                await MainActor.run {
                    self.favoriteGenres = newGenres
                }
                
                // Notify other tabs to refresh their content
                communicationService.notifyGenreUpdate()
                
                print("✅ Updated genres to: \(newGenres)")
                
            } catch {
                print("❌ Failed to update genres: \(error)")
            }
        }
    }
}
