# UpNextAI 🎬

**Movie Discovery App with AI-Powered Search**

UpNextAI is an iOS app that helps users discover movies and TV shows through natural language search and personalized recommendations. Built with SwiftUI and integrated with The Movie Database (TMDB) API.

## Features

### AI-Powered Search
- **Natural Language Queries**: Search using phrases like "Korean comedies from the 90s" or "Brad Pitt action movies"
- **Actor Recognition**: Recognizes 200+ actors and finds their filmographies
- **Director Search**: Find movies by directors like "Christopher Nolan movies"
- **Franchise Detection**: Search for content from Marvel, Star Wars, James Bond, and other franchises
- **Mood-Based Search**: Find content by mood like "something dark" or "feel-good movies"

### Content Discovery
- **Personalized Recommendations**: Suggestions based on your selected favorite genres
- **Real-Time Updates**: Content syncs across all app tabs
- **Content Details**: View movie/TV show information, cast, crew, and streaming availability
- **Watchlist Management**: Save content to watch later

### User Experience
- **No Account Required**: Start using the app immediately
- **Local Data Storage**: All preferences stored on your device
- **Cross-Platform**: Works on iPhone and iPad

## Technical Implementation

### Architecture
```
UpNextAI/
├── Core/
│   ├── AI/                    # Natural Language Processing
│   ├── Data/                  # Core Data + Repository Pattern
│   ├── Network/               # TMDB API Integration
│   └── Coordination/          # App Navigation
├── Features/
│   ├── Discover/              # Content Feed
│   ├── Chat/                  # AI Search Interface  
│   ├── Profile/               # User Preferences
│   └── ContentDetail/         # Detail Views
└── Shared/
    ├── Models/                # Data Models
    └── UI/                    # Reusable Components
```

### Key Technologies
- **SwiftUI**: User interface
- **Core Data**: Local data persistence
- **Combine**: Reactive programming for API calls
- **Natural Language**: Apple's framework for text processing
- **TMDB API**: Movie and TV show data

### AI Components
- **Actor Database**: 200+ famous actors across different regions and eras
- **Movie Database**: 300+ well-known movies and franchises
- **Director Recognition**: 50+ notable directors
- **Genre Mapping**: Comprehensive keyword-to-genre associations
- **Mood Detection**: Sentiment analysis for recommendation filtering

## Getting Started

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/upnextai.git
cd upnextai

# Open in Xcode
open UpNextAI.xcodeproj
```

### API Setup
The app includes a development TMDB API key. For your own deployment:
1. Get an API key from [TMDB](https://www.themoviedb.org/settings/api)
2. Update the key in `TMDBService.swift`

## Example Queries

### Basic Searches
- "Brad Pitt movies"
- "Korean dramas"
- "Christopher Nolan films"

### Complex Searches
- "Korean comedies from the 2000s"
- "Marvel movies but darker"
- "Something like John Wick but funnier"

### Mood-Based
- "Feel-good family movies"
- "Dark psychological thrillers"
- "Light popcorn entertainment"

## Data & Privacy

- **No User Accounts**: No registration or login required
- **Local Storage**: All user data stays on your device
- **Minimal Data**: Only stores movie preferences locally
- **No Tracking**: No analytics or user behavior tracking

## Development

### Architecture Patterns
- **MVVM**: Separation of view logic and business logic
- **Coordinator Pattern**: Navigation management
- **Repository Pattern**: Data access abstraction

### Code Organization
- Feature-based module structure
- Dependency injection for testability
- Async/await for network operations
- Comprehensive error handling

## Contributing

Contributions are welcome. Areas for improvement:
- Expanding the actor/movie databases
- Adding support for more languages
- UI/UX enhancements
- Performance optimizations

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for movie data
- Apple's Natural Language framework for text processing

---

UpNextAI - Discover movies through intelligent search 🎬
