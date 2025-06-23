//
//  OnboardingTVSelectionView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//

import SwiftUI

struct OnboardingTVSelectionView: View {
    let coordinator: OnboardingCoordinator  // Add this
    @State private var selectedShows: Set<String> = []
    // Same grid structure as movies
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    // Top 30 popular TV shows across all genres
    private let topTVShows = [
        // Drama & Acclaimed
        TVShow(title: "Breaking Bad", tmdbId: 1396, posterPath: "/ggFHVNu6YYI5L9pCfOacjizRGt.jpg"),
        TVShow(title: "Better Call Saul", tmdbId: 60059, posterPath: "/fC2HDm5t0kHl7mTm7jxMR31tj7u.jpg"),
        TVShow(title: "The Sopranos", tmdbId: 1398, posterPath: "/rTc7ZXdroqjkKivFPvCPX0Ru7uw.jpg"),
        TVShow(title: "Succession", tmdbId: 63056, posterPath: "/7HW47XbkNQ5fiwQFYGWdw9gs144.jpg"),
        TVShow(title: "The Crown", tmdbId: 4026, posterPath: "/1M876KPjulVwppEpldhdc8V4o68.jpg"),
        TVShow(title: "House of the Dragon", tmdbId: 94997, posterPath: "/z2yahl2uefxDCl0nogcRBstwruJ.jpg"),
        
        // Sci-Fi & Fantasy
        TVShow(title: "Stranger Things", tmdbId: 66732, posterPath: "/49WJfeN0moxb9IPfGn8AIqMGskD.jpg"),
        TVShow(title: "The Mandalorian", tmdbId: 82856, posterPath: "/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg"),
        TVShow(title: "Game of Thrones", tmdbId: 1399, posterPath: "/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg"),
        TVShow(title: "The Witcher", tmdbId: 71912, posterPath: "/cZ0d3rtvXPVvuiX22sP79K3Hmjz.jpg"),
        TVShow(title: "Wednesday", tmdbId: 119051, posterPath: "/9PFonBhy4cQy7Jz20NpMygczOkv.jpg"),
        
        // Comedy Classics
        TVShow(title: "The Office", tmdbId: 2316, posterPath: "/7DJKHzAi83BmQrWLrYYOqcoKfhR.jpg"),
        TVShow(title: "Friends", tmdbId: 1668, posterPath: "/2koX1xLkpTQM4IZebYvKysFW1Nh.jpg"),
        TVShow(title: "Parks and Recreation", tmdbId: 8592, posterPath: "/bcT7Awt2yXJCF4SbSQZYgVTj2aU.jpg"),
        TVShow(title: "Brooklyn Nine-Nine", tmdbId: 48891, posterPath: "/hgRMSOt7a1b8qyQR68vUixJPang.jpg"),
        TVShow(title: "Schitt's Creek", tmdbId: 64770, posterPath: "/iRfSzrPS5VYWQv7KVSEg2BZZL6C.jpg"),
        TVShow(title: "Ted Lasso", tmdbId: 97546, posterPath: "/5fhZdwP1DVJ0FyVH6vrFdHwpXIn.jpg"),
        TVShow(title: "The Good Place", tmdbId: 66573, posterPath: "/qIhsuhoIjD5nco2yCkznEbffeKs.jpg"),
        
        // Modern Hits
        TVShow(title: "The Bear", tmdbId: 136315, posterPath: "/zPyUJuIVdB4v31rUgQyhJOhLCB6.jpg"),
        TVShow(title: "Euphoria", tmdbId: 85552, posterPath: "/3Q0hd3heuWwDWpwcDkhQOA6TYWI.jpg"),
        TVShow(title: "Squid Game", tmdbId: 93405, posterPath: "/dDlEmu3EZ0Pgg93K2SVNLCjCSvE.jpg"),
        
        // Animation & Family
        TVShow(title: "Avatar: The Last Airbender", tmdbId: 246, posterPath: "/d1vQObeHVQ5c4kaXu71PCNWaSOi.jpg"),
        TVShow(title: "Rick and Morty", tmdbId: 60625, posterPath: "/gdIrmf2DdY5mgN6ycVP0XlzKzbE.jpg"),
        TVShow(title: "BoJack Horseman", tmdbId: 61222, posterPath: "/pB9L0jAnEQLMKgexqCEocEW8TA.jpg"),
        TVShow(title: "The Simpsons", tmdbId: 456, posterPath: "/KoFnlbXdkb3sTfNkKp3sSZvSnDu.jpg")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("What TV shows do you love?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap the shows you've enjoyed. We're building your perfect watchlist.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // TV Shows Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(topTVShows, id: \.tmdbId) { show in
                        OnboardingTVPosterView(
                            show: show,
                            isSelected: selectedShows.contains(show.title)
                        ) {
                            toggleShow(show.title)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 20)
                .padding(.bottom, 120) // Space for continue button
            }
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            // Continue Button
            VStack(spacing: 12) {
                if selectedShows.count > 0 {
                    Text("Selected \(selectedShows.count) shows")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button {
                    // Updated to use coordinator with proper error handling
                    Task {
                        do {
                            try await coordinator.saveTVPreferences(Array(selectedShows))
                        } catch {
                            print("❌ Failed to save TV preferences: \(error)")
                        }
                    }
                } label: {
                    HStack {
                        Text("Start Discovering!")
                        Image(systemName: "sparkles")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedShows.isEmpty)
                .opacity(selectedShows.isEmpty ? 0.6 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .background {
                // Gradient background for button area
                LinearGradient(
                    colors: [Color.clear, Color(UIColor.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }
        }
    }
    
    private func toggleShow(_ showTitle: String) {
        if selectedShows.contains(showTitle) {
            selectedShows.remove(showTitle)
        } else {
            selectedShows.insert(showTitle)
        }
    }
    
}

// TV Show poster view (similar to movie version)
struct OnboardingTVPosterView: View {
    let show: TVShow
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Poster Image
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(show.posterPath)")) { image in
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fill)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "tv")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                                
                                Text(show.title)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 4)
                            }
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Green thumbs up overlay when selected
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.8))
                        .overlay {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// Simple TVShow model for onboarding
struct TVShow {
    let title: String
    let tmdbId: Int
    let posterPath: String
}

#Preview {
    // Create a mock coordinator for preview
    let mockRepository = UserPreferenceRepository() // You'll need your real init
    let mockCoordinator = OnboardingCoordinator(
        userRepository: mockRepository,
        onCompletion: { _ in }
    )
    return OnboardingTVSelectionView(coordinator: mockCoordinator)
}
