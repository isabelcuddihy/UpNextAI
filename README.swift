//
//  README.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/15/25.
//

# UpNextAI 🎬

**Intelligent Movie Discovery with AI-Powered Recommendations**

UpNextAI is a privacy-first iOS app that helps users discover their next favorite movie or TV show through intelligent recommendations, streaming availability, and conversational AI assistance.

## ✨ Features

### Current Features
- **Real Movie Data**: Integration with TMDB API for trending movies, ratings, and posters
- **Beautiful UI**: Netflix-inspired interface with smooth scrolling and professional design
- **User Interactions**: Like/dislike system for learning preferences
- **Pull-to-Refresh**: Always get the latest trending content
- **Privacy-First**: No authentication required, all data stays on-device

### Coming Soon
- **Netflix-Style Browse**: Grid layout with detailed movie pages
- **Smart Onboarding**: Quick preference setup for personalized recommendations
- **Streaming Availability**: See where to watch on Netflix, Disney+, Hulu, and more
- **Conversational AI**: Natural language movie discovery ("Show me comedies like The Office")
- **On-Device Learning**: AI that learns your preferences without compromising privacy

## 🚀 Getting Started

### Prerequisites
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/upnextai.git
cd upnextai
```

2. Open the project in Xcode
```bash
open UpNextAI.xcodeproj
```

3. Build and run on your iOS device or simulator

### API Configuration
The app uses The Movie Database (TMDB) API for movie data. The API key is already configured for development purposes.

For production use, obtain your own API key from [TMDB](https://www.themoviedb.org/settings/api) and update `TMDBService.swift`.

## 🏗️ Architecture

UpNextAI follows a clean, feature-based architecture:

```
UpNextAI/
├── App/                    # App lifecycle and configuration
├── Core/                   # Shared utilities and services
│   ├── Data/              # Core Data models and persistence
│   ├── Network/           # API services and networking
│   └── Extensions/        # Swift extensions
├── Domain/                # Business logic and entities
│   ├── Entities/          # Core data models
│   └── UseCases/          # Business use cases
└── Features/              # Feature modules
    ├── ContentFeed/       # Main movie browsing interface
    ├── ContentDetail/     # Movie detail pages
    ├── Onboarding/        # User preference setup
    └── AIChat/            # Conversational AI interface
```

## 🎯 Development Roadmap

### Phase 1: Netflix-Style Browse (In Progress)
- [x] Basic movie feed with TMDB integration
- [ ] Grid layout conversion
- [ ] Movie detail pages
- [ ] Streaming availability integration
- [ ] Smooth navigation transitions

### Phase 2: Smart Onboarding
- [ ] Genre preference selection
- [ ] Favorite actors/directors input
- [ ] Recent favorites to seed recommendations
- [ ] Core Data integration for preferences

### Phase 3: AI-Powered Recommendations
- [ ] On-device machine learning
- [ ] Preference-based filtering
- [ ] Conversational AI chatbot
- [ ] Natural language movie discovery

### Phase 4: Advanced Features
- [ ] Watchlist management
- [ ] Social sharing
- [ ] Review system
- [ ] Advanced filtering options

## 🛠️ Technical Details

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence
- **Combine**: Reactive programming for API calls
- **TMDB API**: Movie and TV show data
- **Core ML**: On-device machine learning (planned)

### API Integration
The app integrates with The Movie Database (TMDB) API for:
- Trending movies and TV shows
- Movie details, cast, and crew
- Poster images and ratings
- Genre-based filtering
- Search functionality

### Privacy & Data
- **No User Accounts**: No registration or login required
- **On-Device Processing**: All AI learning happens locally
- **Minimal Data Collection**: Only movie preferences stored locally
- **GDPR Compliant**: No personal data transmitted to servers

## 🤝 Contributing

This project is currently in active development. Contributions, ideas, and feedback are welcome!

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📱 Screenshots

*Screenshots coming soon as features are completed*

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for providing comprehensive movie data
- The iOS development community for inspiration and best practices

---

**UpNextAI** - Discover your next favorite movie with the power of AI 🎬✨
