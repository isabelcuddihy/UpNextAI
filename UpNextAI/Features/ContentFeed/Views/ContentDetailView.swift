//
//  ContentDetailView.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/21/25.
//
import SwiftUI

struct ContentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ContentDetailViewModel()
    
    let content: TMDBService.TMDBContent
    
    init(content: TMDBService.TMDBContent) {
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main Content - ScrollView
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Section
                        heroSection(geometry: geometry)
                        
                        // Content Details Section
                        contentDetailsSection()
                        
                        // Streaming Availability Section
                        streamingAvailabilitySection()
                        
                        // Action Buttons
                        actionButtonsSection()
                        
                        // Cast/Crew - Simplified
                        castCrewSection()
                        
                        // Similar Content Section
                        if !viewModel.similarContent.isEmpty {
                            similarContentSection()
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            
            // Floating Back Button - Always Visible
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.black.opacity(0.7))
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                            )
                    }
                    .padding(.leading, 16)
                    .padding(.top, 60) // Account for status bar and safe area
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.loadDetails(for: content)
            }
        }
    }
    
    // MARK: - Hero Section
    private func heroSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            // Backdrop Image
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w1280\(content.backdropPath ?? "")")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
            }
            
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    .black.opacity(0.3),
                    .black.opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
            
            // Content Info - Fixed Centering
            VStack(spacing: 12) {
                // Title - Properly Centered
                Text(content.displayTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: geometry.size.width - 64)
                
                // Subtitle Info with Rating
                HStack(spacing: 8) {
                    if let releaseYear = extractYear(from: content.releaseDate) {
                        Text(releaseYear)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    if let runtime = viewModel.contentDetails?.runtime {
                        Text("•")
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(runtime) min")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    if content.voteAverage > 0 {
                        Text("•")
                            .foregroundColor(.white.opacity(0.8))
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", content.voteAverage))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .font(.subheadline)
            }
            .frame(maxWidth: geometry.size.width)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Content Details Section
    private func contentDetailsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Overview
            if let overview = content.overview, !overview.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
            }
            
            // Genres
            if let genres = viewModel.contentDetails?.genres, !genres.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genres")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(genres.prefix(6), id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Streaming Availability Section - SIMPLIFIED
    private func streamingAvailabilitySection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where to Watch")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            if let providers = viewModel.watchProviders {
                streamingProvidersContent(providers: providers)
            } else {
                loadingStreamingContent()
            }
        }
        .padding(.top, 20)
    }

    // Break into separate functions
    private func streamingProvidersContent(providers: WatchProviders) -> some View {
        VStack(spacing: 12) {
            // Subscription services
            if let subscriptionServices = providers.flatrate, !subscriptionServices.isEmpty {
                subscriptionServicesView(services: subscriptionServices)
            }
            
            // Rental services
            if let rentalServices = providers.rent, !rentalServices.isEmpty {
                rentalServicesView(services: rentalServices)
            }
            
            // No providers
            if (providers.flatrate?.isEmpty ?? true) && (providers.rent?.isEmpty ?? true) {
                noProvidersView()
            }
        }
    }

    private func subscriptionServicesView(services: [WatchProvider]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Included with subscription")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(services, id: \.providerId) { service in
                        subscriptionServiceCard(service: service)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func subscriptionServiceCard(service: WatchProvider) -> some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: service.logoPath!)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 24, height: 24)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(service.providerName)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .foregroundColor(.green)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func rentalServicesView(services: [WatchProvider]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rent or buy")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(services, id: \.providerId) { service in
                        rentalServiceCard(service: service)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func rentalServiceCard(service: WatchProvider) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                AsyncImage(url: URL(string: service.logoPath!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 20, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                
                Text(service.providerName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Text("Available")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func loadingStreamingContent() -> some View {
        Text("Loading streaming availability...")
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
    }

    private func noProvidersView() -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            Text("Not currently available for streaming")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
    
    
    // MARK: - Action Buttons Section
    private func actionButtonsSection() -> some View {
        HStack(spacing: 20) {
            // Watchlist Button
            Button(action: {
                viewModel.toggleWatchlist(content)
            }) {
                HStack {
                    Image(systemName: viewModel.isInWatchlist ? "checkmark" : "plus")
                    Text(viewModel.isInWatchlist ? "In Watchlist" : "Add to Watchlist")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isInWatchlist ? Color.green : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Like/Dislike Buttons
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.likeContent(content)
                }) {
                    Image(systemName: viewModel.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.title2)
                        .foregroundColor(viewModel.isLiked ? .green : .primary)
                }
                
                Button(action: {
                    viewModel.dislikeContent(content)
                }) {
                    Image(systemName: viewModel.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .font(.title2)
                        .foregroundColor(viewModel.isDisliked ? .red : .primary)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Cast/Crew Section - Simplified
    private func castCrewSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast & Crew")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 8) {
                // Main cast as text
                if !viewModel.cast.isEmpty {
                    let mainCast = viewModel.cast.prefix(4).map { $0.name }.joined(separator: ", ")
                    HStack {
                        Text("Starring:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    Text(mainCast)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Director/Creator
                if let director = viewModel.crew.first(where: { $0.job.lowercased() == "director" }) {
                    HStack {
                        Text("Directed by:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    Text(director.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if let creator = viewModel.crew.first(where: { $0.department.lowercased() == "writing" }) {
                    HStack {
                        Text("Created by:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    Text(creator.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Similar Content Section - Enhanced
    private func similarContentSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More Like This")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.similarContent.prefix(20), id: \.id) { similarItem in
                        NavigationLink(destination: ContentDetailView(content: similarItem)) {
                            VStack(spacing: 8) {
                                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w342\(similarItem.posterPath ?? "")")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 120, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(spacing: 4) {
                                    Text(similarItem.displayTitle)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    
                                    if similarItem.voteAverage > 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(.yellow)
                                            Text(String(format: "%.1f", similarItem.voteAverage))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .frame(width: 120)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.leading, 20)
                }
                .padding(.trailing, 20)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Mock Data for Streaming Services
    private var mockSubscriptionServices: [StreamingService] {
        [
            StreamingService(name: "Netflix", type: "subscription", price: nil),
            StreamingService(name: "Hulu", type: "subscription", price: nil),
            StreamingService(name: "Disney+", type: "subscription", price: nil)
        ]
    }
    
    private var mockRentalServices: [StreamingService] {
        [
            StreamingService(name: "Apple TV", type: "rent", price: "$3.99"),
            StreamingService(name: "Amazon Prime", type: "rent", price: "$2.99"),
            StreamingService(name: "Vudu", type: "buy", price: "$9.99")
        ]
    }
    
    // Helper to get color for streaming service
    private func colorForService(_ serviceName: String) -> Color {
        switch serviceName.lowercased() {
        case "netflix": return .red
        case "hulu": return .green
        case "disney+": return .blue
        case "apple tv": return .blue
        case "amazon prime": return .orange
        case "vudu": return .purple
        default: return .gray
        }
    }
    
    // Helper to get SF Symbol icon for streaming service
    private func iconForService(_ serviceName: String) -> String {
        switch serviceName.lowercased() {
        case "netflix": return "tv.circle.fill"
        case "hulu": return "play.circle.fill"
        case "disney+": return "star.circle.fill"
        case "apple tv": return "tv.circle"
        case "amazon prime": return "play.rectangle.fill"
        case "vudu": return "rectangle.stack.fill"
        default: return "tv.fill"
        }
    }
    
    // MARK: - Helper Methods
    private func extractYear(from dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        return String(dateString.prefix(4))
    }
}
