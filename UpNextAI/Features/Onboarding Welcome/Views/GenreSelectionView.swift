//
//  GenreSelectionView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.

import SwiftUI

struct GenreSelectionView: View {
    @State private var selectedGenres: Set<String> = []
    let onContinue: ([String]) -> Void
    
    private let genres = [
        "Action", "Comedy", "Drama", "Horror", "Romance",
        "Sci-Fi", "Fantasy", "Animation", "Documentary", "Crime",
        "Thriller", "Family", "Adventure", "Mystery", "Music"
    ]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("What genres do you enjoy?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Select all that apply. We'll use this to personalize your recommendations.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Genre Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(genres, id: \.self) { genre in
                        GenreSelectionButton(
                            genre: genre,
                            isSelected: selectedGenres.contains(genre)
                        ) {
                            toggleGenre(genre)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            
            Spacer()
        }
        .overlay(alignment: .bottom) {
            // Continue Button
            VStack(spacing: 12) {
                if selectedGenres.count > 0 {
                    Text("Selected \(selectedGenres.count) genres")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button {
                    
                    onContinue(Array(selectedGenres))
                } label: {
                    HStack {
                        Text("Continue to Movies")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedGenres.isEmpty)
                .opacity(selectedGenres.isEmpty ? 0.6 : 1.0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .background {
                LinearGradient(
                    colors: [Color.clear, Color(UIColor.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }
        }
    }
    
    private func toggleGenre(_ genre: String) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
}

struct GenreSelectionButton: View {
    let genre: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(genre)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GenreSelectionView { genres in
        print("Selected genres: \(genres)")
    }
}
