//
//  ContentViewModel.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/19/25.
//
import Foundation
import Combine

// MARK: - Content ViewModel
@MainActor
class ContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var contentSections: [ContentSection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let tmdbService = TMDBService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasContent: Bool {
        !contentSections.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoading && contentSections.isEmpty && errorMessage == nil
    }
    
    // MARK: - Initialization
    init() {
        // Simple initialization - working directly with TMDBService for now
    }
    
    // MARK: - Public Methods
    
    /// Load all content sections for the main feed
    func loadMainFeed() async {
        isLoading = true
        errorMessage = nil
        contentSections = []
        
        do {
            // Load multiple content sections concurrently
            async let trendingContent = tmdbService.fetchTrending()
            async let popularContent = tmdbService.fetchPopular()
            async let topRatedContent = tmdbService.fetchTopRated()
            
            // Wait for all requests to complete
            let trending = try await trendingContent
            let popular = try await popularContent
            let topRated = try await topRatedContent
            
            // Create content sections
            contentSections = [
                ContentSection(
                    title: "Trending Now",
                    content: trending,
                    category: .trending
                ),
                ContentSection(
                    title: "Popular",
                    content: popular,
                    category: .popular
                ),
                ContentSection(
                    title: "Critically Acclaimed",
                    content: topRated,
                    category: .topRated
                )
            ]
            
            print("✅ Loaded \(contentSections.count) content sections")
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Load content sections with genre categories
    func loadGenreBasedFeed() async {
        isLoading = true
        errorMessage = nil
        contentSections = []
        
        do {
            // Start with trending
            let trending = try await tmdbService.fetchTrending()
            var sections = [ContentSection(
                title: "Trending Now",
                content: trending,
                category: .trending
            )]
            
            // Add popular as well
            let popular = try await tmdbService.fetchPopular()
            sections.append(ContentSection(
                title: "Popular",
                content: popular,
                category: .popular
            ))
            
            // TODO: Add genre-specific sections when you implement fetchByGenre in TMDBService
            // For now, just use trending and popular
            
            contentSections = sections
            print("✅ Loaded \(contentSections.count) content sections")
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Refresh current content
    func refresh() async {
        await loadMainFeed()
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        let message: String
        
        if let tmdbError = error as? TMDBError {
            switch tmdbError {
            case .invalidURL:
                message = "Invalid request. Please try again."
            case .invalidResponse:
                message = "Server error. Please try again later."
            case .decodingError:
                message = "Data parsing error. Please try again."
            }
        } else {
            message = "Something went wrong: \(error.localizedDescription)"
        }
        
        errorMessage = message
        print("❌ Error loading content: \(error)")
    }
}

// MARK: - Content Interaction Methods
extension ContentViewModel {
    /// Handle user liking content (will integrate with Core Data later)
    func likeContent(_ content: TMDBService.TMDBContent) {
        print("❤️ Liked: \(content.title)")
        // TODO: Save to Core Data preferences
        // TODO: Update AI learning model
    }
    
    /// Handle user disliking content (will integrate with Core Data later)
    func dislikeContent(_ content: TMDBService.TMDBContent) {
        print("👎 Disliked: \(content.title)")
        // TODO: Save to Core Data preferences
        // TODO: Update AI learning model
    }
    
    /// Add content to watchlist (will implement later)
    func addToWatchlist(_ content: TMDBService.TMDBContent) {
        print("📚 Added to watchlist: \(content.title)")
        // TODO: Implement watchlist functionality
    }
    
    /// Handle movie tap - will navigate to detail view
    func handleMovieTap(_ content: TMDBService.TMDBContent) {
        print("🎬 Tapped movie: \(content.title)")
        // TODO: Navigate to detail view
    }
}
