//
//  ChatBotModel.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/28/25.
//

import Foundation
import Combine
import SwiftUI
import NaturalLanguage

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var currentInput = ""
    
    private let userRepository: UserPreferenceRepository
    private let contentRepository: ContentRepository
    private let communicationService: TabCommunicationService
    private let tmdbService = TMDBService.shared
    
    // NEW: AI Integration
    private let naturalLanguageProcessor = NaturalLanguageProcessor()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserPreferenceRepository,
         contentRepository: ContentRepository,
         communicationService: TabCommunicationService) {
        self.userRepository = userRepository
        self.contentRepository = contentRepository
        self.communicationService = communicationService
        
        setupCommunication()
        loadWelcomeMessage()
    }
    
    private func setupCommunication() {
        // Listen for watchlist updates from other tabs
        communicationService.$watchlistUpdated
            .sink { [weak self] _ in
                if let newItem = self?.communicationService.newWatchlistItem {
                    self?.handleWatchlistUpdate(newItem)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            type: .botText("Hi! I'm your AI movie assistant. Try asking me things like:\n\n• \"Show me funny Korean movies\"\n• \"Something like John Wick\"\n• \"80s comedies\"\n• \"British shows from the 2010s\"\n\nWhat are you in the mood for? 🎬")
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(type: .userText(text))
        messages.append(userMessage)
        
        // Start typing indicator
        isTyping = true
        
        Task {
            // NEW: Use AI to process the message
            await processUserMessageWithAI(text)
        }
    }
    
    // NEW: AI-Powered Message Processing
    private func processUserMessageWithAI(_ text: String) async {
        print("🤖 Processing user query: '\(text)'")
        
        // Step 1: Use Apple AI to understand the query
        let searchParams = naturalLanguageProcessor.parseMovieQuery(text)
        
        // Step 2: Give user feedback about what we understood
        if searchParams.isValidForSearch {
            await addBotMessage("I'm looking for \(searchParams.searchDescription)...")
        } else {
            await addBotMessage("Let me find some great recommendations for you...")
        }
        
        // Step 3: Get movie recommendations using AI analysis
        let recommendations = await getAIRecommendations(using: searchParams)
        
        // Step 4: Show results
        await MainActor.run {
            isTyping = false
            
            if !recommendations.isEmpty {
                let resultMessage = ChatMessage(type: .movieRecommendations(recommendations))
                messages.append(resultMessage)
            } else {
                let fallbackMessage = ChatMessage(
                    type: .botText("I couldn't find anything specific for that, but here are a few options based on your preferences!")
                )
                messages.append(fallbackMessage)
                
                // Show personalized fallback recommendations
                Task {
                    let personalizedRecs = await getPersonalizedFallbackRecommendations()
                    await MainActor.run {
                        let fallbackRecsMessage = ChatMessage(type: .movieRecommendations(personalizedRecs))
                        messages.append(fallbackRecsMessage)
                    }
                }
            }
        }
    }
    
    // IMPROVED: Better AI recommendation logic
    private func getAIRecommendations(using params: SearchParameters) async -> [Content] {
        print("🎯 Search strategy: \(params.searchStrategy)")
        print("🗓️ Year range: \(params.yearRange?.description ?? "none")")
        print("🎭 Genres: \(params.genres)")
        
        do {
            var tmdbResults: [TMDBService.TMDBContent] = []
            
            switch params.searchStrategy {
            case .actorSearch:
                // SIMPLE: Use improved actor search for better results
                if let actor = params.actorName {
                    print("🎭 Searching for movies with actor: \(actor)")
                    tmdbResults = try await tmdbService.searchActorSimple(actor)
                }
                
            case .titleSearch:
                // Use TMDB search for "like [Title]" queries
                if let title = params.similarToTitle {
                    print("🔍 Searching for content similar to: \(title)")
                    tmdbResults = try await tmdbService.search(title)
                }
                
            case .endpointSearch:
                // SPECIAL: Handle romantic comedies with multiple genres
                if params.genres.count == 2 && params.genres.contains("Romance") && params.genres.contains("Comedy") {
                    print("💕 Searching for romantic comedies")
                    tmdbResults = try await searchRomanticComedies(yearRange: params.yearRange)
                }
                // IMPROVED: Handle year ranges with genre searches
                else if let yearRange = params.yearRange, !params.genres.isEmpty {
                    print("🎯 Year + Genre search: \(params.genres.first!) from \(yearRange)")
                    tmdbResults = try await searchWithYearAndGenre(
                        genre: params.genres.first!,
                        yearRange: yearRange
                    )
                } else if let endpoint = params.suggestedTMDBEndpoint() {
                    print("🎯 Using specialized endpoint: \(endpoint)")
                    tmdbResults = try await tmdbService.fetchByGenre(endpoint)
                }
                
            case .keywordSearch:
                // IMPROVED: Better keyword search with filters
                if let yearRange = params.yearRange, !params.genres.isEmpty {
                    // Best case: we have both year and genre
                    print("🎯 Advanced search: \(params.genres.first!) from \(yearRange)")
                    tmdbResults = try await searchWithYearAndGenre(
                        genre: params.genres.first!,
                        yearRange: yearRange
                    )
                } else if let yearRange = params.yearRange {
                    // We have year but no specific genre - use broader search
                    print("🎯 Year-based search: \(yearRange)")
                    tmdbResults = try await searchByYearRange(yearRange)
                } else if !params.genres.isEmpty {
                    // We have genre but no year
                    print("🎯 Genre search: \(params.genres)")
                    tmdbResults = try await tmdbService.fetchByGenre(params.genres.first!.lowercased())
                } else {
                    // Fallback to keyword search
                    let searchQuery = params.toSearchQuery()
                    if !searchQuery.isEmpty {
                        print("🔍 Keyword search: \(searchQuery)")
                        tmdbResults = try await tmdbService.search(searchQuery)
                    }
                }
                
            case .fallback:
                print("📈 Using fallback: trending content")
                tmdbResults = try await tmdbService.fetchTrending()
            }
            
            // IMPROVED: Don't apply additional year filtering if we already did targeted year+genre search
            if let yearRange = params.yearRange,
               params.searchStrategy != .endpointSearch &&
               params.searchStrategy != .keywordSearch {
                tmdbResults = filterByYearRange(tmdbResults, yearRange: yearRange)
                print("📅 After year filtering: \(tmdbResults.count) items")
            }
            
            // IMPROVED: Better quality filtering and sorting
            let qualityFiltered = tmdbResults
                .filter { ($0.voteAverage ?? 0) > 6.0 } // Higher quality threshold
                .filter { $0.voteAverage != nil } // Remove unrated content
                .sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) } // Sort by rating
            
            let recommendations = qualityFiltered.prefix(6).compactMap { tmdbMovie in
                convertTMDBToContent(tmdbMovie)
            }
            
            print("✅ Found \(recommendations.count) AI recommendations (filtered for quality)")
            return recommendations
            
        } catch {
            print("❌ AI recommendation search failed: \(error)")
            return []
        }
    }

    // NEW: Search by year range (for decade-based queries)
    private func searchByYearRange(_ yearRange: ClosedRange<Int>) async throws -> [TMDBService.TMDBContent] {
        // For decade searches, let's try popular movies from that era
        // This is a simplified approach - you could make this more sophisticated
        let midYear = (yearRange.lowerBound + yearRange.upperBound) / 2
        let searchQuery = "\(midYear)"
        
        let results = try await tmdbService.search(searchQuery)
        return filterByYearRange(results, yearRange: yearRange)
    }

    // NEW: Search with year and genre filtering - FIXED for better decade searches
    private func searchWithYearAndGenre(genre: String, yearRange: ClosedRange<Int>) async throws -> [TMDBService.TMDBContent] {
        print("🎯 Searching for \(genre) content from \(yearRange)")
        
        // For decade-based searches, we need to use TMDB's discover API with year filters
        // But since your current endpoints don't support year filtering, let's use a different approach
        
        // Strategy 1: Search for the genre + decade keywords
        let decadeKeyword = getDecadeKeyword(for: yearRange)
        let searchQuery = "\(genre) \(decadeKeyword)"
        print("🔍 Searching with query: '\(searchQuery)'")
        
        let searchResults = try await tmdbService.search(searchQuery)
        let filtered = filterByYearRange(searchResults, yearRange: yearRange)
        
        // If we got good results, return them
        if filtered.count >= 3 {
            print("✅ Found \(filtered.count) results from search approach")
            return filtered
        }
        
        // Strategy 2: Get all genre content and filter by year (fallback)
        print("🔄 Not enough search results, trying genre endpoint...")
        let genreResults = try await tmdbService.fetchByGenre(genre.lowercased())
        let yearFiltered = filterByYearRange(genreResults, yearRange: yearRange)
        
        if yearFiltered.count >= 3 {
            print("✅ Found \(yearFiltered.count) results from genre filtering")
            return yearFiltered
        }
        
        // Strategy 3: Expand search to slightly broader time range if still no results
        print("🔄 Still not enough results, expanding time range...")
        let expandedRange = expandYearRange(yearRange)
        let expandedResults = filterByYearRange(genreResults, yearRange: expandedRange)
        
        print("✅ Final results: \(expandedResults.count) items from expanded range")
        return expandedResults
    }
    
    // Helper to get decade keyword for search
    private func getDecadeKeyword(for yearRange: ClosedRange<Int>) -> String {
        switch yearRange.lowerBound {
        case 1980...1989: return "80s"
        case 1990...1999: return "90s"
        case 2000...2009: return "2000s"
        case 2010...2019: return "2010s"
        case 2020...2024: return "2020s"
        default: return "\(yearRange.lowerBound)s"
        }
    }
    
    // NEW: Search for romantic comedies (both Romance + Comedy genres)
    private func searchRomanticComedies(yearRange: ClosedRange<Int>?) async throws -> [TMDBService.TMDBContent] {
        // Search for romance movies first
        let romanceResults = try await tmdbService.fetchByGenre("romance")
        
        // Filter for movies that also have comedy elements (check genre_ids)
        let romComResults = romanceResults.filter { movie in
            // TMDB Comedy genre ID is 35
            return movie.genreIds?.contains(35) == true
        }
        
        // Apply year filtering if specified
        if let yearRange = yearRange {
            return filterByYearRange(romComResults, yearRange: yearRange)
        }
        
        print("💕 Found \(romComResults.count) romantic comedies")
        return romComResults
    }
    
    // Helper to expand year range if we're not finding enough content
    private func expandYearRange(_ originalRange: ClosedRange<Int>) -> ClosedRange<Int> {
        let startYear = max(1970, originalRange.lowerBound - 5)
        let endYear = min(2024, originalRange.upperBound + 5)
        return startYear...endYear
    }

    // NEW: Filter TMDB results by year range
    private func filterByYearRange(_ results: [TMDBService.TMDBContent], yearRange: ClosedRange<Int>) -> [TMDBService.TMDBContent] {
        return results.filter { movie in
            // Extract year from release date
            if let dateString = movie.releaseDate ?? movie.firstAirDate,
               let year = extractYear(from: dateString) {
                let inRange = yearRange.contains(year)
                if inRange {
                    print("📅 Keeping '\(movie.displayTitle)' from \(year)")
                } else {
                    print("📅 Filtering out '\(movie.displayTitle)' from \(year) (outside \(yearRange))")
                }
                return inRange
            }
            print("📅 No date found for '\(movie.displayTitle)', filtering out")
            return false
        }
    }

    // Helper to extract year from TMDB date string
    private func extractYear(from dateString: String) -> Int? {
        let components = dateString.components(separatedBy: "-")
        if let yearString = components.first, let year = Int(yearString) {
            return year
        }
        return nil
    }
    
    // NEW: Convert TMDB to Content (matches your existing pattern)
    private func convertTMDBToContent(_ tmdbMovie: TMDBService.TMDBContent) -> Content {
        return Content(
            tmdbID: tmdbMovie.id,
            title: tmdbMovie.displayTitle,
            overview: tmdbMovie.overview ?? "No description available",
            releaseDate: Date(), // Could parse tmdbMovie.displayDate if needed
            genres: [], // Could map from tmdbMovie.genreIds if needed
            contentType: tmdbMovie.isMovie ? .movie : .tvShow,
            rating: tmdbMovie.voteAverage ?? 5.1,
            genreIds: tmdbMovie.genreIds ?? [],
            mediaType: tmdbMovie.mediaType,
            posterPath: tmdbMovie.posterPath,
            backdropPath: tmdbMovie.backdropPath
        )
    }
    
    // Helper to add bot messages
    private func addBotMessage(_ text: String) async {
        await MainActor.run {
            let botMessage = ChatMessage(type: .botText(text))
            messages.append(botMessage)
        }
    }
    
    // NEW: Get personalized fallback from user's recommendation row
    private func getPersonalizedFallbackRecommendations() async -> [Content] {
        print("🎯 Getting personalized fallback recommendations...")
        
        do {
            // Get current user profile first
            guard let userProfile = try await userRepository.getUserProfile() else {
                print("⚠️ No user profile found, using trending fallback")
                return await getFallbackRecommendations()
            }
            
            // Get user's favorite genres (same logic as your ContentViewModel)
            let userGenres = try await userRepository.getLikedGenres(for: userProfile)
            
            if userGenres.isEmpty {
                print("⚠️ No user genres found, using trending fallback")
                return await getFallbackRecommendations()
            }
            
            // Shuffle genres like ContentViewModel does
            let shuffledGenres = userGenres.shuffled()
            print("🔀 User's favorite genres: \(shuffledGenres)")
            
            var personalizedContent: [Content] = []
            
            // Try to get content from user's top 2-3 favorite genres
            for genre in shuffledGenres.prefix(3) {
                do {
                    let tmdbResults = try await tmdbService.fetchByGenre(genre.lowercased())
                    let qualityFiltered = tmdbResults
                        .filter { ($0.voteAverage ?? 0) > 6.5 } // High quality only
                        .prefix(3) // Just a few from each genre
                    
                    let genreContent = qualityFiltered.compactMap { convertTMDBToContent($0) }
                    personalizedContent.append(contentsOf: genreContent)
                    
                    print("📚 Added \(genreContent.count) items from \(genre)")
                    
                    // Stop when we have enough recommendations
                    if personalizedContent.count >= 5 {
                        break
                    }
                } catch {
                    print("⚠️ Failed to fetch \(genre): \(error)")
                    continue
                }
            }
            
            // Remove duplicates and limit to 5
            let uniqueContent = Array(Set(personalizedContent.map { $0.tmdbID }))
                .compactMap { tmdbID in personalizedContent.first { $0.tmdbID == tmdbID } }
                .prefix(5)
            
            if !uniqueContent.isEmpty {
                print("✅ Returning \(uniqueContent.count) personalized recommendations")
                return Array(uniqueContent)
            } else {
                print("⚠️ No personalized content found, using trending fallback")
                return await getFallbackRecommendations()
            }
            
        } catch {
            print("❌ Error getting personalized recommendations: \(error)")
            return await getFallbackRecommendations()
        }
    }
    
    // Fallback recommendations (generic trending - only used as last resort)
    private func getFallbackRecommendations() async -> [Content] {
        do {
            let tmdbMovies = try await tmdbService.fetchPopularMovies()
            return tmdbMovies.prefix(5).map { convertTMDBToContent($0) }
        } catch {
            print("⚠️ Failed to fetch fallback recommendations: \(error)")
            return []
        }
    }
    
    private func handleWatchlistUpdate(_ content: Content) {
        let acknowledgment = ChatMessage(
            type: .systemNotification("✅ Added \"\(content.title)\" to your watchlist! Want more suggestions like this?")
        )
        messages.append(acknowledgment)
    }
    
    // LEGACY: Keep this for backward compatibility (not used anymore)
    private func createMockRecommendations() async -> [Content] {
        return await getFallbackRecommendations()
    }
}

// MARK: - Chat Message Models (No changes needed)

struct ChatMessage: Identifiable {
    let id = UUID()
    let type: ChatMessageType
    let timestamp = Date()
}

enum ChatMessageType {
    case userText(String)
    case botText(String)
    case movieRecommendations([Content])
    case systemNotification(String)
}
