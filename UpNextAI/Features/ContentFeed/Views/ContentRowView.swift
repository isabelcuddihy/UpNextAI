//
//  ContentRowView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//

import SwiftUI

struct ContentRowView: View {
    let title: String
    let content: [TMDBContent]
    let onItemTap: (TMDBContent) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section title
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Horizontal scrolling row
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(content, id: \.id) { movie in
                        NavigationLink(destination: ContentDetailView(content: movie)) {
                            ContentPosterView(movie: movie)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onTapGesture {
                            onItemTap(movie)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ContentPosterView: View {
    let movie: TMDBContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Movie poster
            AsyncImage(url: constructPosterURL(from: movie.posterPath)) { image in
                image
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2/3, contentMode: .fill)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Movie title (optional, can remove for cleaner look)
            Text(movie.displayTitle)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
        }
    }
}

// Helper function to construct TMDB image URLs
private func constructPosterURL(from path: String?) -> URL? {
    guard let path = path else { return nil }
    return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
}

#Preview {
    NavigationView {
        ContentRowView(
            title: "Trending Now",
            content: [],
            onItemTap: { _ in }
        )
    }
}
