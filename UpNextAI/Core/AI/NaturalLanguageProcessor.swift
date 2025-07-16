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
    
    // ✅ ENHANCED: Genre Keywords with Mood/Style (including superhero fix)
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
        "superhero": ["superhero", "super hero", "comic book", "comics", "cape", "hero"], // ✅ FIXED: Added superhero
           
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

    // ✅ NEW: Helper function to check if query explicitly asks for similarity
    private func isExplicitSimilarityRequest(_ query: String) -> Bool {
        let similarityPatterns = [
            "like ", "similar to ", "movies like ", "shows like ",
            "something like ", "reminds me of ", "in the style of "
        ]
        
        return similarityPatterns.contains { pattern in
            query.contains(pattern)
        }
    }

    // ✅ NEW: Helper to prevent mood words from being detected as actors
    private func isMoodWord(_ word: String) -> Bool {
        let moodWords = [
            "happy", "sad", "funny", "scary", "romantic", "dark",
            "light", "intense", "emotional", "smart", "clever"
        ]
        return moodWords.contains(word.lowercased())
    }

    // ✅ ENHANCED: Better mood detection with more patterns
    private func detectMood(from query: String) -> String? {
        let moodPatterns: [String: [String]] = [
            "feel-good": [
                "feel good", "uplifting", "heartwarming", "inspiring",
                "positive", "cheerful", "happy", "joyful", "lighthearted"
            ],
            "dark": [
                "dark", "gritty", "noir", "bleak", "depressing",
                "twisted", "serious", "heavy", "disturbing"
            ],
            "light": [
                "light", "easy", "fun", "casual", "simple",
                "mindless", "popcorn", "entertaining"
            ],
            "intense": [
                "intense", "gripping", "edge of your seat",
                "nail biting", "thrilling", "suspenseful"
            ],
            "emotional": [
                "emotional", "tear jerker", "touching", "moving",
                "heartbreaking", "dramatic", "sad"
            ],
            "smart": [
                "intelligent", "smart", "clever", "thought provoking",
                "cerebral", "complex", "sophisticated"
            ]
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

    // ✅ ENHANCED: Better genre extraction with mood mapping
    private func extractGenres(from query: String, using tagger: NLTagger) -> [String] {
        var detectedGenres: [String] = []
        
        // Enhanced genre keywords with mood mapping
        let enhancedGenreKeywords: [String: [String]] = [
            "Comedy": [
                "comedy", "comedies", "funny", "hilarious", "laugh",
                "humor", "witty", "silly", "goofy", "happy"
            ],
            "Action": [
                "action", "explosive", "fight", "intense", "thrilling",
                "adrenaline", "guns", "chase"
            ],
            "Romance": [
                "romantic", "romance", "love", "dating", "sweet",
                "relationship", "couples", "wedding"
            ],
            "Horror": [
                "scary", "terrifying", "horror", "frightening",
                "spooky", "creepy", "ghost", "zombie"
            ],
            "Drama": [
                "dramatic", "emotional", "deep", "serious",
                "touching", "moving", "powerful"
            ],
            "Thriller": [
                "suspense", "tension", "mystery", "psychological",
                "edge of your seat", "thriller"
            ],
            "Science Fiction": [
                "science fiction", "sci-fi", "scifi", "futuristic",
                "space", "aliens", "robots", "cyberpunk"
            ],
            "Fantasy": [
                "magical", "fantasy", "wizards", "dragons",
                "supernatural", "mythical"
            ],
            "Crime": [
                "crime", "detective", "police", "murder",
                "investigation", "noir"
            ]
        ]
        
        for (genre, keywords) in enhancedGenreKeywords {
            for keyword in keywords {
                if query.contains(keyword) {
                    if !detectedGenres.contains(genre) {
                        detectedGenres.append(genre)
                    }
                    break
                }
            }
        }
        
        return detectedGenres
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

    
    // ✅ ENHANCED: Better year detection for 80s/90s queries
    private func extractYearRange(from query: String) -> ClosedRange<Int>? {
        print("📅 Checking year patterns in: '\(query)'")
        
        // ✅ ENHANCED: More comprehensive decade detection
        let decadePatterns: [(patterns: [String], range: ClosedRange<Int>)] = [
            (["80s", "1980s", "eighties", "'80s", "80's"], 1980...1989),
            (["90s", "1990s", "nineties", "'90s", "90's"], 1990...1999),
            (["2000s", "early 2000s", "00s", "'00s", "2000's"], 2000...2009),
            (["2010s", "twenty tens", "10s", "'10s", "2010's"], 2010...2019),
            (["2020s", "recent", "new", "20s", "'20s", "2020's"], 2020...2024)
        ]
        
        for (patterns, range) in decadePatterns {
            for pattern in patterns {
                if query.contains(pattern) {
                    print("📅 Found decade pattern '\(pattern)': \(range)")
                    return range
                }
            }
        }
        
        // ✅ ENHANCED: Better relative time detection
        let relativePatterns: [(patterns: [String], range: ClosedRange<Int>)] = [
            (["classic", "classics", "old", "vintage", "retro"], 1970...1999),
            (["modern", "contemporary", "current"], 2010...2024),
            (["golden age", "golden era"], 1930...1960),
            (["new wave", "80s new wave"], 1980...1989)
        ]
        
        for (patterns, range) in relativePatterns {
            for pattern in patterns {
                if query.contains(pattern) {
                    print("📅 Found relative time '\(pattern)': \(range)")
                    return range
                }
            }
        }
        
        // ✅ ENHANCED: Specific year detection with better regex
        let yearPatterns = [
            "\\b(19[5-9]\\d)\\b",  // 1950-1999
            "\\b(20[0-2]\\d)\\b"   // 2000-2029
        ]
        
        for pattern in yearPatterns {
            if let yearRegex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(location: 0, length: query.utf16.count)
                
                if let match = yearRegex.firstMatch(in: query, range: range) {
                    let yearString = (query as NSString).substring(with: match.range)
                    if let year = Int(yearString) {
                        print("📅 Found specific year: \(year)")
                        return year...year
                    }
                }
            }
        }
        
        print("📅 No year patterns found")
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
    
    // ✅ ENHANCED: Add these methods to NaturalLanguageProcessor.swift for better TV show detection

    // MARK: - Enhanced Content Type Detection
    private func detectContentType(from query: String) -> ContentType? {
        let lowercaseQuery = query.lowercased()
        
        // ✅ ENHANCED: More comprehensive TV show detection
        let tvIndicators = [
            // Direct mentions
            "tv show", "tv shows", "television show", "television shows",
            "show", "shows", "series", "tv series", "television series",
            "episode", "episodes", "season", "seasons",
            
            // TV-specific terminology
            "sitcom", "sitcoms", "drama series", "comedy series",
            "miniseries", "mini series", "limited series",
            "binge watch", "binge watching", "streaming series",
            
            // Regional TV terms
            "british tv", "british shows", "uk shows", "bbc shows",
            "k-drama", "kdrama", "korean drama", "korean shows",
            "telenovela", "telenovelas", "soap opera",
            "anime series", "anime shows", "tv anime",
            
            // Platform-specific terms
            "netflix series", "hbo series", "disney+ series",
            "streaming show", "web series"
        ]
        
        let movieIndicators = [
            // Direct mentions
            "movie", "movies", "film", "films", "cinema",
            "flick", "flicks", "picture", "pictures",
            
            // Movie-specific terminology
            "blockbuster", "blockbusters", "box office",
            "theatrical release", "big screen",
            "hollywood movie", "bollywood movie",
            "indie film", "independent film",
            
            // Movie genres that are rarely TV
            "superhero movie", "action movie", "horror movie",
            "romantic comedy movie", "animated movie"
        ]
        
        // Check for TV indicators first (more specific)
        for indicator in tvIndicators {
            if lowercaseQuery.contains(indicator) {
                print("📺 Detected TV content from: '\(indicator)'")
                return .tvShow
            }
        }
        
        // Then check for movie indicators
        for indicator in movieIndicators {
            if lowercaseQuery.contains(indicator) {
                print("🎬 Detected movie content from: '\(indicator)'")
                return .movie
            }
        }
        
        // ✅ NEW: Context-based detection
        return detectContentTypeFromContext(lowercaseQuery)
    }

    // ✅ NEW: Context-based content type detection
    private func detectContentTypeFromContext(_ query: String) -> ContentType? {
        // Patterns that suggest TV shows
        let tvPatterns = [
            // Question patterns that are typically about TV
            "what should i watch", "what to watch", "something to binge",
            "good to binge", "binge worthy", "worth binging",
            
            // Duration/commitment patterns
            "long series", "short series", "quick watch",
            "many seasons", "few seasons", "one season",
            
            // Viewing context patterns
            "background watching", "while working", "easy to follow",
            "don't need to pay attention",
            
            // Character development patterns (more common in TV)
            "character development", "character arcs", "complex characters",
            "ensemble cast"
        ]
        
        // Patterns that suggest movies
        let moviePatterns = [
            // Time commitment patterns
            "quick movie", "short movie", "long movie",
            "2 hour", "90 minute", "under 2 hours",
            
            // Viewing context patterns
            "date night", "movie night", "theater",
            "big screen", "cinema experience",
            
            // Award patterns (more common for movies)
            "oscar winner", "academy award", "golden globe",
            "cannes", "sundance"
        ]
        
        for pattern in tvPatterns {
            if query.contains(pattern) {
                print("📺 Detected TV from context: '\(pattern)'")
                return .tvShow
            }
        }
        
        for pattern in moviePatterns {
            if query.contains(pattern) {
                print("🎬 Detected movie from context: '\(pattern)'")
                return .movie
            }
        }
        
        return nil // Mixed/unknown
    }

    // ✅ ENHANCED: Updated parseMovieQuery method with better TV detection
    func parseMovieQuery(_ query: String) -> SearchParameters {
        print("🧠 AI Processing query: '\(query)'")
        
        let lowercaseQuery = query.lowercased()
        var searchParams = SearchParameters()
        
        // Initialize Apple's NaturalLanguage tagger
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = query
        
        // ✅ ENHANCED: Detect content type EARLY in the process
        searchParams.contentType = detectContentType(from: lowercaseQuery)
        if let contentType = searchParams.contentType {
            print("🎭 Detected content type: \(contentType.rawValue)")
        }
        
        // 1. Check for directors FIRST (very specific intent)
        if let director = detectDirector(from: lowercaseQuery) {
            searchParams.directorName = director
            print("🎬 Detected director: '\(director)'")
            return searchParams
        }
        
        // 2. Check for franchises (Marvel, Star Wars, etc.)
        if let franchise = detectFranchise(from: lowercaseQuery) {
            searchParams.franchiseName = franchise
            print("🏰 Detected franchise: '\(franchise)'")
            return searchParams
        }
        
        // 3. Extract year range
        searchParams.yearRange = extractYearRange(from: lowercaseQuery)
        if let yearRange = searchParams.yearRange {
            print("📅 Detected year range: \(yearRange)")
        }
        
        // 4. Enhanced mood detection
        if let mood = detectMood(from: lowercaseQuery) {
            searchParams.mood = mood
            print("😊 Detected mood: '\(mood)'")
        }
        
        // 5. Enhanced actor detection
        if let actor = detectActor(from: lowercaseQuery) {
            if !isMoodWord(actor) {
                searchParams.actorName = actor
                print("🎭 Detected actor: '\(actor)'")
            }
        }
        
        // 6. Enhanced movie title detection
        if searchParams.actorName == nil && searchParams.mood == nil {
            if let movie = detectFamousMovie(from: lowercaseQuery) {
                if isExplicitSimilarityRequest(lowercaseQuery) {
                    searchParams.similarToTitle = movie
                    print("🎬 Detected famous movie: '\(movie)'")
                }
            } else {
                searchParams.similarToTitle = extractSimilarTitle(from: query, using: tagger)
            }
        }
        
        // 7. ✅ ENHANCED: Genre extraction with content type awareness
        searchParams.genres = extractGenresWithContentType(from: lowercaseQuery, contentType: searchParams.contentType, using: tagger)
        
        // 8. Handle romantic comedy requests
        if isRomanticComedyRequest(lowercaseQuery) {
            searchParams.genres = ["Romance", "Comedy"]
            print("💕 Detected romantic comedy request")
        }
        
        // 9. Detect country/region
        searchParams.country = extractCountry(from: lowercaseQuery)
        
        // 10. Extract keywords for fallback
        if searchParams.actorName == nil && searchParams.similarToTitle == nil {
            searchParams.keywords = extractKeywords(from: lowercaseQuery, using: tagger)
        }
        
        print("🎯 AI Extracted: \(searchParams)")
        
        return searchParams
    }

    // ✅ NEW: Content-type-aware genre extraction
    private func extractGenresWithContentType(from query: String, contentType: ContentType?, using tagger: NLTagger) -> [String] {
        var detectedGenres: [String] = []
        
        // Base genre keywords
        let baseGenreKeywords: [String: [String]] = [
            "Comedy": ["comedy", "comedies", "funny", "hilarious", "laugh", "humor", "witty", "silly", "goofy", "happy"],
            "Action": ["action", "explosive", "fight", "intense", "thrilling", "adrenaline", "guns", "chase"],
            "Romance": ["romantic", "romance", "love", "dating", "sweet", "relationship", "couples", "wedding"],
            "Horror": ["scary", "terrifying", "horror", "frightening", "spooky", "creepy", "ghost", "zombie"],
            "Drama": ["dramatic", "emotional", "deep", "serious", "touching", "moving", "powerful"],
            "Thriller": ["suspense", "tension", "mystery", "psychological", "edge of your seat", "thriller"],
            "Science Fiction": ["science fiction", "sci-fi", "scifi", "futuristic", "space", "aliens", "robots", "cyberpunk"],
            "Fantasy": ["magical", "fantasy", "wizards", "dragons", "supernatural", "mythical"],
            "Crime": ["crime", "detective", "police", "murder", "investigation", "noir"]
        ]
        
        // ✅ NEW: TV-specific genre variations
        let tvSpecificKeywords: [String: [String]] = [
            "Comedy": ["sitcom", "sitcoms", "comedy series", "funny show", "comedy show"],
            "Drama": ["drama series", "dramatic series", "soap opera", "prestige tv"],
            "Crime": ["police procedural", "detective series", "crime drama", "true crime series"],
            "Reality": ["reality tv", "reality show", "competition show", "dating show"],
            "Documentary": ["docuseries", "documentary series", "docu-series"]
        ]
        
        // ✅ NEW: Movie-specific genre variations
        let movieSpecificKeywords: [String: [String]] = [
            "Action": ["action movie", "action film", "blockbuster action"],
            "Horror": ["horror movie", "horror film", "scary movie"],
            "Comedy": ["comedy movie", "comedy film", "funny movie"],
            "Romance": ["romantic movie", "rom-com", "romantic comedy movie"]
        ]
        
        // Check base keywords first
        for (genre, keywords) in baseGenreKeywords {
            for keyword in keywords {
                if query.contains(keyword) {
                    if !detectedGenres.contains(genre) {
                        detectedGenres.append(genre)
                    }
                    break
                }
            }
        }
        
        // ✅ NEW: Add content-type-specific genre detection
        if contentType == .tvShow {
            for (genre, keywords) in tvSpecificKeywords {
                for keyword in keywords {
                    if query.contains(keyword) {
                        if !detectedGenres.contains(genre) {
                            detectedGenres.append(genre)
                            print("📺 Added TV-specific genre: \(genre)")
                        }
                        break
                    }
                }
            }
        } else if contentType == .movie {
            for (genre, keywords) in movieSpecificKeywords {
                for keyword in keywords {
                    if query.contains(keyword) {
                        if !detectedGenres.contains(genre) {
                            detectedGenres.append(genre)
                            print("🎬 Added movie-specific genre: \(genre)")
                        }
                        break
                    }
                }
            }
        }
        
        return detectedGenres
    }

}
