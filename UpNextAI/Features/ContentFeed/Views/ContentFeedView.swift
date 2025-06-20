//
//  ContentFeedView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import SwiftUI

struct ContentFeedView: View {
    @State private var movies: [TMDBService.TMDBContent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if isLoading {
                        ProgressView("Loading movies...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else if movies.isEmpty {
                        Text("No movies found")
                            .foregroundColor(.gray)
                            .padding(.top, 100)
                    } else {
                        ForEach(movies, id: \.id) { movie in
                            ContentCardView(movie: movie)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("UpNext AI")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadMovies()
            }
        }
        .task {
            await loadMovies()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    @MainActor
    private func loadMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            movies = try await TMDBService.shared.fetchTrending()
            print("✅ Loaded \(movies.count) movies for feed")
        } catch {
            errorMessage = "Failed to load movies: \(error.localizedDescription)"
            print("❌ Error loading movies: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    ContentFeedView()
}
