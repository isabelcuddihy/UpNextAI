//
//  EditGenresView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/29/25.
//

import SwiftUI

struct EditGenresView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGenres: Set<String>
    let currentGenres: [String]
    let onSave: ([String]) -> Void
    
    // All available genres from your TMDB endpoints
    private let allGenres = [
        "Action", "Comedy", "Drama", "Horror", "Romance",
        "Sci-Fi", "Fantasy", "Animation", "Documentary", "True Crime",
        "Thriller", "Kids & Family", "Adventure", "Mystery", "Superhero",
        "K-Drama", "Bollywood", "British TV", "Telenovelas", "Historical",
        "Crime"  // Added this since you have crimeTV endpoint
    ]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(currentGenres: [String], onSave: @escaping ([String]) -> Void) {
        self.currentGenres = currentGenres
        self.onSave = onSave
        self._selectedGenres = State(initialValue: Set(currentGenres))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Edit Your Favorite Genres")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select all genres you enjoy. This will update your personalized recommendations.")
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
                        ForEach(allGenres.sorted(), id: \.self) { genre in
                            GenreEditButton(
                                genre: genre,
                                isSelected: selectedGenres.contains(genre)
                            ) {
                                toggleGenre(genre)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                Spacer()
            }
            .navigationTitle("Edit Genres")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(Array(selectedGenres))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedGenres.isEmpty)
                }
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

struct GenreEditButton: View {
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
    EditGenresView(currentGenres: ["Comedy", "K-Drama", "Adventure"]) { newGenres in
        print("Updated genres: \(newGenres)")
    }
}
