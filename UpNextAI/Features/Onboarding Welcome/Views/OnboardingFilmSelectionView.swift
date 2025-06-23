//
//  OnboardingFilmSelectionView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//

import SwiftUI

struct OnboardingMovieSelectionView: View {
    let coordinator: OnboardingCoordinator  // Add this
    @State private var selectedMovies: Set<String> = []
    // Reuse your existing grid structure
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    // Top 30 popular movies across all genres
    private let topMovies = [
        // Modern Blockbusters & Popular
        Movie(title: "Top Gun: Maverick", tmdbId: 361743, posterPath: "/62HCnUTziyWcpDaBO2i1DX17ljH.jpg"),
        Movie(title: "Spider-Man: No Way Home", tmdbId: 634649, posterPath: "/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg"),
        Movie(title: "Barbie", tmdbId: 346698, posterPath: "/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg"),
        Movie(title: "Oppenheimer", tmdbId: 872585, posterPath: "/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg"),
        Movie(title: "Avatar: The Way of Water", tmdbId: 76600, posterPath: "/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg"),
        Movie(title: "Black Panther", tmdbId: 284054, posterPath: "/uxzzxijgPIY7slzFvMotPv8wjKA.jpg"),
        Movie(title: "Dune", tmdbId: 438631, posterPath: "/d5NXSklXo0qyIYkgV94XAgMIckC.jpg"),
        
        // Acclaimed Classics
        Movie(title: "The Dark Knight", tmdbId: 155, posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg"),
        Movie(title: "Pulp Fiction", tmdbId: 680, posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg"),
        Movie(title: "Inception", tmdbId: 27205, posterPath: "/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg"),
        Movie(title: "The Matrix", tmdbId: 603, posterPath: "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg"),
        Movie(title: "Interstellar", tmdbId: 157336, posterPath: "/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg"),
        Movie(title: "Parasite", tmdbId: 496243, posterPath: "/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg"),
        Movie(title: "Everything Everywhere All at Once", tmdbId: 545611, posterPath: "/w3LxiVYdWWRvEVdn5RYq6jIqkb1.jpg"),
        
        // Family & Animation
        Movie(title: "Finding Nemo", tmdbId: 12, posterPath: "/eHuGQ10FUzK1mdOY69wF5pGgEf5.jpg"),
        Movie(title: "Toy Story", tmdbId: 862, posterPath: "/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg"),
        Movie(title: "Frozen", tmdbId: 109445, posterPath: "/kgwjIb2JDHRhNk13lmSxiClFjVk.jpg"),
        Movie(title: "Spider-Man: Into the Spider-Verse", tmdbId: 324857, posterPath: "/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg"),
        Movie(title: "Encanto", tmdbId: 568124, posterPath: "/4j0PNHkMr5ax3IA8tjtxcmPU3QT.jpg"),
        Movie(title: "The Lion King", tmdbId: 8587, posterPath: "/sKCr78MXSLixwmZ8DyJLrpMsd15.jpg"),
        
        // Romance & Comedy
        Movie(title: "Titanic", tmdbId: 597, posterPath: "/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg"),
        Movie(title: "La La Land", tmdbId: 313369, posterPath: "/uDO8zWDhfWwoFdKS4fzkUJt0Rf0.jpg"),
        Movie(title: "Pretty Woman", tmdbId: 621, posterPath: "/kOqOPSAYzydEGqCvdFLcLn5g2X0.jpg"),
        Movie(title: "The Proposal", tmdbId: 18240, posterPath: "/sUdKF81lPHW8v9iXzF5xXJ1sX8j.jpg"),
        Movie(title: "Forrest Gump", tmdbId: 13, posterPath: "/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("What movies do you love?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap the movies you've enjoyed. We'll use this to find your perfect next watch.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Movie Grid - Reusing your existing structure
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(topMovies, id: \.tmdbId) { movie in
                        OnboardingPosterView(
                            movie: movie,
                            isSelected: selectedMovies.contains(movie.title)
                        ) {
                            toggleMovie(movie.title)
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
                if selectedMovies.count > 0 {
                    Text("Selected \(selectedMovies.count) movies")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button {
                       // Updated to use coordinator
                    Task {
                            do {
                                try await coordinator.saveMoviePreferences(Array(selectedMovies))
                            } catch {
                                print("❌ Failed to save movie preferences: \(error)")
                            }
                        }
                    } label: {
                        HStack {
                            Text("Continue to TV Shows")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                .disabled(selectedMovies.isEmpty)
                .opacity(selectedMovies.isEmpty ? 0.6 : 1.0)
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
    
    private func toggleMovie(_ movieTitle: String) {
        if selectedMovies.contains(movieTitle) {
            selectedMovies.remove(movieTitle)
        } else {
            selectedMovies.insert(movieTitle)
        }
    }

}

// Adapted version of your ContentPosterView for onboarding
struct OnboardingPosterView: View {
    let movie: Movie
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Poster Image (reusing your AsyncImage structure)
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")) { image in
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fill)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                                
                                Text(movie.title)
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

// Simple Movie model for onboarding
struct Movie {
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
    return OnboardingMovieSelectionView(coordinator: mockCoordinator)
}
