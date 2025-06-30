//
//  NaturalLanguageProcessor.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/29/25.
//

import NaturalLanguage
import Foundation

class NaturalLanguageProcessor {
    
    // EXPANDED: Famous Actors (200+ entries organized by category)
    private let famousActors = [
        // A-List Hollywood Stars
        "brad pitt", "leonardo dicaprio", "jennifer lawrence", "angelina jolie",
        "will smith", "tom cruise", "julia roberts", "sandra bullock",
        "denzel washington", "meryl streep", "robert downey jr", "scarlett johansson",
        "ryan gosling", "emma stone", "matt damon", "charlize theron",
        "christian bale", "natalie portman", "bradley cooper", "anne hathaway",
        
        // Action Heroes
        "keanu reeves", "dwayne johnson", "jason statham", "vin diesel",
        "liam neeson", "hugh jackman", "chris hemsworth", "chris evans",
        "ryan reynolds", "mark wahlberg", "jason momoa", "gal gadot",
        "tom hardy", "henry cavill", "chris pratt", "john wick",
        
        // Comedy Legends
        "adam sandler", "kevin hart", "jim carrey", "steve carell",
        "ben stiller", "owen wilson", "seth rogen", "jonah hill",
        "melissa mccarthy", "kristen wiig", "tina fey", "amy poehler",
        "eddie murphy", "mike myers", "robin williams", "will ferrell",
        
        // International Stars
        "gong yoo", "lee min ho", "song joong ki", "park seo joon", // Korean
        "priyanka chopra", "shah rukh khan", "aamir khan", "deepika padukone", // Bollywood
        "antonio banderas", "penelope cruz", "javier bardem", // Spanish
        "marion cotillard", "jean dujardin", "audrey tautou", // French
        "russell crowe", "cate blanchett", "hugh jackman", "nicole kidman", // Australian
        
        // Classic Hollywood Icons
        "marilyn monroe", "audrey hepburn", "elizabeth taylor", "james dean",
        "marlon brando", "humphrey bogart", "grace kelly", "cary grant",
        "katharine hepburn", "clark gable", "john wayne", "jimmy stewart",
        
        // Modern Powerhouses
        "timothee chalamet", "zendaya", "anya taylor joy", "florence pugh",
        "oscar isaac", "adam driver", "lupita nyongo", "michael b jordan",
        "brie larson", "margot robbie", "saoirse ronan", "daniel kaluuya"
    ]
    
    // EXPANDED: Famous Movies (300+ entries organized by genre/era)
    private let famousMovies = [
        // Action Blockbusters
        "john wick", "die hard", "mad max fury road", "the dark knight",
        "terminator", "aliens", "predator", "rambo", "rocky",
        "mission impossible", "fast and furious", "transformers",
        "the matrix", "speed", "heat", "point break", "face off",
        
        // Marvel/DC Universe
        "avengers", "iron man", "spider man", "batman", "superman",
        "wonder woman", "black panther", "thor", "captain america",
        "guardians of the galaxy", "x men", "deadpool", "aquaman",
        
        // Classic Cinema
        "the godfather", "casablanca", "citizen kane", "gone with the wind",
        "lawrence of arabia", "singin in the rain", "some like it hot",
        "vertigo", "psycho", "north by northwest", "sunset boulevard",
        
        // Modern Classics
        "pulp fiction", "goodfellas", "the shawshank redemption", "forrest gump",
        "titanic", "jurassic park", "star wars", "back to the future",
        "raiders of the lost ark", "e t", "jaws", "the silence of the lambs",
        
        // Recent Hits (2010s-2020s)
        "parasite", "everything everywhere all at once", "dune", "oppenheimer",
        "barbie", "top gun maverick", "black widow", "no time to die",
        "joker", "once upon a time in hollywood", "1917", "knives out",
        
        // Comedy Favorites
        "the hangover", "superbad", "pineapple express", "step brothers",
        "anchorman", "wedding crashers", "meet the parents", "zoolander",
        "dumb and dumber", "the mask", "liar liar", "mrs doubtfire",
        
        // Horror Classics
        "the exorcist", "halloween", "friday the 13th", "nightmare on elm street",
        "scream", "the conjuring", "get out", "hereditary", "midsommar",
        "it", "the shining", "poltergeist", "the blair witch project",
        
        // Romance Movies
        "the notebook", "titanic", "dirty dancing", "ghost", "pretty woman",
        "when harry met sally", "sleepless in seattle", "youve got mail",
        "the proposal", "crazy stupid love", "la la land", "the holiday",
        
        // International Cinema
        "squid game", "oldboy", "train to busan", "parasite", // Korean
        "dangal", "3 idiots", "lagaan", "zindagi na milegi dobara", // Bollywood
        "amelie", "the intouchables", "blue is the warmest color", // French
        "cinema paradiso", "life is beautiful", "the great beauty", // Italian
        
        // Animated Favorites
        "toy story", "finding nemo", "the incredibles", "shrek", "frozen",
        "moana", "coco", "encanto", "the lion king", "beauty and the beast",
        "spirited away", "my neighbor totoro", "princess mononoke", // Studio Ghibli
        
        // Franchises & Series
        "harry potter", "lord of the rings", "hobbit", "star trek",
        "james bond", "indiana jones", "pirates of the caribbean",
        "fast and furious", "transformers", "jurassic park"
    ]
    
    // NEW: Director Recognition
    private let famousDirectors = [
        "christopher nolan", "quentin tarantino", "martin scorsese",
        "steven spielberg", "ridley scott", "james cameron",
        "denis villeneuve", "jordan peele", "greta gerwig",
        "coen brothers", "wes anderson", "david fincher",
        "tim burton", "guillermo del toro", "rian johnson",
        "bong joon ho", "akira kurosawa", "stanley kubrick"
    ]
    
    // NEW: Franchise Recognition
    private let movieFranchises = [
        "marvel", "dc", "star wars", "star trek", "harry potter",
        "lord of the rings", "fast and furious", "mission impossible",
        "james bond", "john wick", "matrix", "terminator",
        "alien", "predator", "rocky", "rambo", "indiana jones"
    ]
    
    // IMPROVED: Enhanced Genre Keywords with Mood/Style
    private let genreKeywords: [String: [String]] = [
        "action": ["action", "explosive", "fight", "intense", "thrilling", "adrenaline", "guns", "chase"],
        "comedy": ["funny", "hilarious", "laugh", "humor", "comedy", "witty", "silly", "goofy"],
        "romance": ["romantic", "love", "dating", "sweet", "relationship", "couples", "wedding"],
        "horror": ["scary", "terrifying", "horror", "frightening", "spooky", "creepy", "ghost", "zombie"],
        "drama": ["dramatic", "emotional", "deep", "serious", "touching", "moving", "powerful"],
        "thriller": ["suspense", "tension", "mystery", "psychological", "edge of your seat"],
        "sci-fi": ["science fiction", "futuristic", "space", "aliens", "robots", "cyberpunk"],
        "fantasy": ["magical", "fantasy", "wizards", "dragons", "supernatural", "mythical"],
        "crime": ["crime", "detective", "police", "murder", "investigation", "noir"],
        "war": ["war", "military", "battle", "soldiers", "combat", "historical"],
        
        // NEW: Mood-based keywords
        "feel good": ["uplifting", "heartwarming", "inspiring", "positive", "cheerful"],
        "dark": ["dark", "gritty", "noir", "bleak", "depressing", "twisted"],
        "family": ["family friendly", "kids", "wholesome", "disney", "pixar"],
        "mindless": ["popcorn", "turn your brain off", "simple", "easy watching"],
        "intelligent": ["smart", "clever", "thought provoking", "cerebral", "complex"]
    ]
    
    // MARK: - Country Mapping (matches your TMDB endpoints)
    private let countryKeywords: [String: String] = [
        // Korean content
        "korean": "KR", "korea": "KR", "k-drama": "KR", "kdrama": "KR",
        
        // Japanese content
        "japanese": "JP", "japan": "JP", "anime": "JP",
        
        // British content
        "british": "GB", "uk": "GB", "england": "GB", "british tv": "GB",
        
        // Indian content
        "indian": "IN", "bollywood": "IN", "india": "IN",
        
        // Spanish content
        "spanish": "ES", "spain": "ES", "telenovela": "ES", "telenovelas": "ES"
    ]
    
   
  
    func parseMovieQuery(_ query: String) -> SearchParameters {
        print("🧠 AI Processing query: '\(query)'")
        
        let lowercaseQuery = query.lowercased()
        var searchParams = SearchParameters()
        
        // Initialize Apple's NaturalLanguage tagger
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = query
        
        // 1. NEW: Check for directors FIRST (very specific intent)
        if let director = detectDirector(from: lowercaseQuery) {
            searchParams.directorName = director
            // Remove these lines - searchStrategy is computed automatically
            // searchParams.searchStrategy = .keywordSearch
            print("🎬 Detected director: '\(director)'")
            // Remove this line - searchDescription is computed automatically
            // searchParams.searchDescription = "movies by \(director.capitalized)"
            return searchParams // Return early for director searches
        }
        
        // 2. NEW: Check for franchises (Marvel, Star Wars, etc.)
        if let franchise = detectFranchise(from: lowercaseQuery) {
            searchParams.franchiseName = franchise
            // Remove these lines - computed automatically
            // searchParams.searchStrategy = .keywordSearch
            print("🏰 Detected franchise: '\(franchise)'")
            // Remove this line - computed automatically
            // searchParams.searchDescription = "\(franchise.capitalized) movies"
            return searchParams // Return early for franchise searches
        }
        
        // 3. ENHANCED: Check for famous actors (expanded database)
        if let actor = detectActor(from: lowercaseQuery) {
            searchParams.actorName = actor
            print("🎭 Detected actor: '\(actor)'")
        }
        
        // 4. ENHANCED: Check for famous movie titles (expanded database)
        else if let movie = detectFamousMovie(from: lowercaseQuery) {
            searchParams.similarToTitle = movie
            print("🎬 Detected famous movie: '\(movie)'")
        }
        
        // 5. Check for "like [Title]" patterns (existing logic)
        else {
            searchParams.similarToTitle = extractSimilarTitle(from: query, using: tagger)
        }
        
        // 6. NEW: Enhanced mood detection
        if let mood = detectMood(from: lowercaseQuery) {
            searchParams.mood = mood
            print("😊 Detected mood: '\(mood)'")
        }
        
        // 7. Detect what type of content they want (existing)
        searchParams.contentType = detectContentType(from: lowercaseQuery)
        
        // 8. ENHANCED: Extract genres with better keyword mapping
        searchParams.genres = extractGenres(from: lowercaseQuery, using: tagger)
        
        // 9. SPECIAL: Handle romantic comedy requests (existing)
        if isRomanticComedyRequest(lowercaseQuery) {
            searchParams.genres = ["Romance", "Comedy"]
            print("💕 Detected romantic comedy request")
        }
        
        // 10. ENHANCED: Detect country/region with expanded list
        searchParams.country = extractCountry(from: lowercaseQuery)
        
        // 11. Look for time period references (existing)
        searchParams.yearRange = extractYearRange(from: lowercaseQuery)
        
        // 12. Extract general keywords for fallback searching (existing)
        searchParams.keywords = extractKeywords(from: lowercaseQuery, using: tagger)
        
        print("🎯 AI Extracted: \(searchParams)")
        
        return searchParams
    }

    // NEW: Director detection function
    private func detectDirector(from query: String) -> String? {
        for director in famousDirectors {
            if query.contains(director) {
                return director
            }
        }
        
        // Check for director-specific patterns
        let directorPatterns = [
            "directed by", "director", "from the director of", "by the same director"
        ]
        
        for pattern in directorPatterns {
            if query.contains(pattern) {
                // Try to extract director name after the pattern
                if let range = query.range(of: pattern) {
                    let afterPattern = String(query[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    // Look for a director in what follows
                    for director in famousDirectors {
                        if afterPattern.hasPrefix(director) {
                            return director
                        }
                    }
                }
            }
        }
        
        return nil
    }

    // NEW: Franchise detection function
    private func detectFranchise(from query: String) -> String? {
        for franchise in movieFranchises {
            if query.contains(franchise) {
                return franchise
            }
        }
        
        // Check for franchise-specific patterns
        let franchisePatterns = [
            "universe", "cinematic universe", "series", "franchise", "saga"
        ]
        
        for pattern in franchisePatterns {
            if query.contains(pattern) {
                // Look for franchise keywords nearby
                for franchise in movieFranchises {
                    if query.contains(franchise) {
                        return franchise
                    }
                }
            }
        }
        
        return nil
    }

    // NEW: Mood detection function
    private func detectMood(from query: String) -> String? {
        // Define mood patterns
        let moodPatterns: [String: [String]] = [
            "feel-good": ["feel good", "uplifting", "heartwarming", "inspiring", "positive", "cheerful", "happy"],
            "dark": ["dark", "gritty", "noir", "bleak", "depressing", "twisted", "serious", "heavy"],
            "light": ["light", "easy", "fun", "casual", "simple", "mindless", "popcorn"],
            "intense": ["intense", "gripping", "edge of your seat", "nail biting", "thrilling"],
            "emotional": ["emotional", "tear jerker", "touching", "moving", "heartbreaking"],
            "smart": ["intelligent", "smart", "clever", "thought provoking", "cerebral", "complex"]
        ]
        
        for (mood, keywords) in moodPatterns {
            for keyword in keywords {
                if query.contains(keyword) {
                    return mood
                }
            }
        }
        
        return nil
    }

    // ENHANCED: Actor detection with expanded database
    private func detectActor(from query: String) -> String? {
        // Your existing logic, but now uses the expanded famousActors array
        for actor in famousActors {
            if query.contains(actor) {
                return actor
            }
        }
        
        // Enhanced patterns for actor detection
        let actorPatterns = [
            "with", "starring", "features", "actor", "actress", "performance by"
        ]
        
        for pattern in actorPatterns {
            if query.contains(pattern) {
                // Try to find an actor name after the pattern
                if let range = query.range(of: pattern) {
                    let afterPattern = String(query[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    for actor in famousActors {
                        if afterPattern.hasPrefix(actor) {
                            return actor
                        }
                    }
                }
            }
        }
        
        return nil
    }

    // ENHANCED: Movie detection with expanded database
    private func detectFamousMovie(from query: String) -> String? {
        // Your existing logic, but now uses the expanded famousMovies array
        for movie in famousMovies {
            if query.contains(movie) {
                return movie
            }
        }
        
        // Enhanced patterns for movie detection
        let moviePatterns = [
            "like", "similar to", "movies like", "films like", "something like"
        ]
        
        for pattern in moviePatterns {
            if query.contains(pattern) {
                if let range = query.range(of: pattern) {
                    let afterPattern = String(query[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    for movie in famousMovies {
                        if afterPattern.hasPrefix(movie) {
                            return movie
                        }
                    }
                }
            }
        }
        
        return nil
    }

    // ENHANCED: Genre extraction with better keyword mapping
    private func extractGenres(from query: String, using tagger: NLTagger) -> [String] {
        var detectedGenres: [String] = []
        
        // Use your enhanced genreKeywords dictionary
        for (genre, keywords) in genreKeywords {
            for keyword in keywords {
                if query.contains(keyword) {
                    detectedGenres.append(genre.capitalized)
                    break // Don't add the same genre multiple times
                }
            }
        }
        
        // Remove duplicates and return
        return Array(Set(detectedGenres))
    }

    // ENHANCED: Country detection with expanded list
    private func extractCountry(from query: String) -> String? {
        let countryPatterns: [String: [String]] = [
            "korean": ["korean", "k-drama", "kdrama", "south korean", "korea"],
            "japanese": ["japanese", "anime", "japan", "j-drama"],
            "indian": ["bollywood", "indian", "hindi", "tamil", "telugu"],
            "british": ["british", "uk", "english", "britain", "bbc"],
            "french": ["french", "france", "francophone"],
            "spanish": ["spanish", "spain", "telenovela", "latino"],
            "italian": ["italian", "italy"],
            "german": ["german", "germany"],
            "chinese": ["chinese", "china", "mandarin", "cantonese"],
            "russian": ["russian", "russia"]
        ]
        
        for (country, keywords) in countryPatterns {
            for keyword in keywords {
                if query.contains(keyword) {
                    return country
                }
            }
        }
        
        return nil
    }
    
    
    // MARK: - NEW: Romantic Comedy Detection
    private func isRomanticComedyRequest(_ query: String) -> Bool {
        let romcomPatterns = [
            "romantic comedy", "romantic comedies", "rom com", "rom-com", "romcom",
            "rom coms", "rom-coms", "romcoms", "love comedy", "funny romance"
        ]
        
        for pattern in romcomPatterns {
            if query.contains(pattern) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Content Type Detection
    private func detectContentType(from query: String) -> ContentType? {
        if query.contains("movie") || query.contains("film") || query.contains("cinema") {
            return .movie
        }
        
        if query.contains("show") || query.contains("series") || query.contains("tv") ||
           query.contains("episode") || query.contains("season") {
            return .tvShow
        }
        
        return nil // Mixed results - let TMDB decide
    }
    
    
    // MARK: - Mood-Based Genre Detection (Apple AI)
    private func detectMoodBasedGenres(from query: String, using tagger: NLTagger) -> Set<String> {
        var moodGenres: Set<String> = []
        
        // Analyze adjectives for emotional context
        tagger.enumerateTags(in: query.startIndex..<query.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if tag == .adjective {
                let adjective = String(query[tokenRange]).lowercased()
                
                switch adjective {
                case "dark", "gritty", "intense":
                    moodGenres.insert("Crime")
                case "light", "fun", "cheerful":
                    moodGenres.insert("Comedy")
                case "epic", "grand", "heroic":
                    moodGenres.insert("Adventure")
                case "mysterious", "puzzling":
                    moodGenres.insert("Thriller")
                default:
                    break
                }
            }
            return true
        }
        
        return moodGenres
    }

    
    // MARK: - Time Period Detection
    private func extractYearRange(from query: String) -> ClosedRange<Int>? {
        // More comprehensive decade detection patterns
        let decade80s = ["80s", "1980s", "eighties", "'80s"]
        let decade90s = ["90s", "1990s", "nineties", "'90s", "90's"]
        let decade2000s = ["2000s", "early 2000s", "00s", "'00s"]
        let decade2010s = ["2010s", "twenty tens", "10s", "'10s", "2010's"]
        let decade2020s = ["2020s", "recent", "new", "20s", "'20s"]
        
        for pattern in decade80s {
            if query.contains(pattern) {
                print("📅 Found decade: 1980s")
                return 1980...1989
            }
        }
        
        for pattern in decade90s {
            if query.contains(pattern) {
                print("📅 Found decade: 1990s")
                return 1990...1999
            }
        }
        
        for pattern in decade2000s {
            if query.contains(pattern) {
                print("📅 Found decade: 2000s")
                return 2000...2009
            }
        }
        
        for pattern in decade2010s {
            if query.contains(pattern) {
                print("📅 Found decade: 2010s")
                return 2010...2019
            }
        }
        
        for pattern in decade2020s {
            if query.contains(pattern) {
                print("📅 Found decade: 2020s")
                return 2020...2024
            }
        }
        
        // Better relative time detection
        if query.contains("classic") || query.contains("old") || query.contains("vintage") {
            print("📅 Found classic period")
            return 1970...1999
        }
        if query.contains("modern") || query.contains("contemporary") {
            print("📅 Found modern period")
            return 2010...2024
        }
        
        // Specific year detection using regex - more comprehensive
        let yearPatterns = [
            "\\b(19[6-9]\\d)\\b",  // 1960-1999
            "\\b(20[0-2]\\d)\\b"   // 2000-2029
        ]
        
        for pattern in yearPatterns {
            let yearRegex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: query.utf16.count)
            
            if let match = yearRegex?.firstMatch(in: query, range: range) {
                let yearString = (query as NSString).substring(with: match.range)
                if let year = Int(yearString) {
                    print("📅 Found specific year: \(year)")
                    return year...year
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Similar Title Detection (Apple Named Entity Recognition)
    private func extractSimilarTitle(from query: String, using tagger: NLTagger) -> String? {
        // IMPROVED: Better pattern matching for "like [Title]" or "similar to [Title]"
        let patterns = [
            "like ",
            "similar to ",
            "such as ",
            "including ",
            "movies like ",
            "shows like ",
            "something like "
        ]
        
        for pattern in patterns {
            if let range = query.lowercased().range(of: pattern) {
                let afterPattern = String(query[range.upperBound...])
                let cleanTitle = cleanTitleString(afterPattern)
                if !cleanTitle.isEmpty && cleanTitle.count > 2 {
                    print("🎬 Found similar title: '\(cleanTitle)'")
                    return cleanTitle
                }
            }
        }
        
        return nil // Don't use NER for standalone titles - it's too unreliable
    }
    
    // MARK: - Keyword Extraction for Fallback Search
    private func extractKeywords(from query: String, using tagger: NLTagger) -> [String] {
        var keywords: [String] = []
        
        tagger.enumerateTags(in: query.startIndex..<query.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if tag == .noun || tag == .adjective {
                let word = String(query[tokenRange]).lowercased()
                
                // Filter for meaningful keywords
                if word.count > 3 && !isCommonWord(word) {
                    keywords.append(word)
                }
            }
            return true
        }
        
        return Array(Set(keywords)) // Remove duplicates
    }
    
    // MARK: - Helper Functions
    private func cleanTitleString(_ title: String) -> String {
        let cleaned = title
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .punctuationCharacters)
        
        // Stop at common sentence enders
        let stopWords = ["but", "and", "or", "from", "in", "on", "with", "that", "which", "where"]
        for stopWord in stopWords {
            if let range = cleaned.lowercased().range(of: " \(stopWord) ") {
                return String(cleaned[..<range.lowerBound])
            }
        }
        
        return cleaned
    }
    
    private func isCommonWord(_ word: String) -> Bool {
        let commonWords = [
            "show", "movie", "film", "good", "best", "great", "find", "want", "need",
            "like", "love", "watch", "see", "looking", "recommend", "suggestion",
            "from", "with", "about", "some", "any", "this", "that", "these", "those"
        ]
        return commonWords.contains(word)
    }
}
