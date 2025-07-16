//
//  Untitled.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import SwiftUI

struct ContentCardView: View {
    let movie: TMDBContent
    @State private var isLiked: Bool = false
    @State private var isDisliked: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Movie Poster and Basic Info
            HStack(spacing: 12) {
                // Poster Image
                AsyncImage(url: URL(string: movie.fullPosterURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Movie Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.displayTitle)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if !movie.displayDate.isEmpty {
                        Text(movie.displayDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", movie.voteAverage ?? 5.1))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // Overview
            if let overview = movie.overview, !overview.isEmpty {
                Text(overview)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.primary)
            }
            
            // Action Buttons
            HStack {
                Spacer()
                
                Button(action: {
                    dislikeMovie()
                }) {
                    Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.title2)
                        .foregroundColor(isDisliked ? .red : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                    .frame(width: 40)
                
                Button(action: {
                    likeMovie()
                }) {
                    Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.title2)
                        .foregroundColor(isLiked ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func likeMovie() {
        isLiked.toggle()
        if isLiked {
            isDisliked = false
            print("👍 Liked: \(movie.displayTitle)")
            // TODO: Save to Core Data
        }
    }
    
    private func dislikeMovie() {
        isDisliked.toggle()
        if isDisliked {
            isLiked = false
            print("👎 Disliked: \(movie.displayTitle)")
            // TODO: Save to Core Data
        }
    }
}

#Preview {
    // Mock data for preview
    let mockMovie = TMDBContent(
        id: 1,
        title: "Sample Movie",
        name: nil,
        overview: "This is a sample movie description to show how the card looks with longer text content.",
        posterPath: nil,
        backdropPath: nil,
        releaseDate: "2024-01-01",
        firstAirDate: nil,
        voteAverage: 8.5,
        genreIds: [28, 12],
        mediaType: "movie"
    )
    
    ContentCardView(movie: mockMovie)
        .padding()
}
