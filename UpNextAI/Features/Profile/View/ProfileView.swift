//
//  ProfileView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/28/25.
//

import Foundation
import SwiftUI


struct ProfileView: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @State private var showingGenreEditor = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // User Info Section
                    UserInfoSection(userProfile: viewModel.userProfile)
                    
                    // Watchlist Section
                    WatchlistSection(watchlist: viewModel.watchlist)
                    
                    // Favorite Genres Section
                    FavoriteGenresSection(genres: viewModel.favoriteGenres) {
                        showingGenreEditor = true
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingGenreEditor) {
                EditGenresView(currentGenres: viewModel.favoriteGenres) { newGenres in
                    viewModel.updateGenres(newGenres)
                }
            }
        }
    }
}

struct UserInfoSection: View {
    let userProfile: UserProfileCoreData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back!")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let profile = userProfile {
                Text(profile.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Member since \(profile.createdDate?.formatted(date: .abbreviated, time: .omitted) ?? "Recently")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Loading profile...")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct WatchlistSection: View {
    let watchlist: [Content]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Watchlist")
                .font(.title2)
                .fontWeight(.semibold)
            
            if watchlist.isEmpty {
                Text("No movies in your watchlist yet. Add some from the chat or discover tabs!")
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(watchlist) { movie in
                            WatchlistItemCard(movie: movie)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct WatchlistItemCard: View {
    let movie: Content
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: movie.posterURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "tv")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 100, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(movie.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
}

struct FavoriteGenresSection: View {
    let genres: [String]
    let onEditGenres: () -> Void  // Add this parameter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Favorite Genres")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Edit") {
                    onEditGenres()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if genres.isEmpty {
                Text("Complete your profile to see your favorite genres here.")
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(genres, id: \.self) { genre in
                        Text(genre)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
    }
}
