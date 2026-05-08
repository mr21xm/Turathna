# تراثنا (Our Heritage) - UAE Quiz Game Show

"تراثنا" is a premium, native iOS game show app built with SwiftUI, designed for group play (2–10 players). The game is themed around the rich culture, heritage, and identity of the United Arab Emirates.

## 🎮 Features

- **UAE Themed Experience**: 50 high-quality questions in Arabic covering history, geography, traditions, food, and more.
- **Interactive Spinning Wheel**: A custom-built wheel with point values, jackpots, and special segments like "إفلاس" (Bankruptcy) and "راحت عليك" (Skip Turn).
- **RTL & Arabic First**: Full Right-to-Left (RTL) layout support with a modern minimalist design using the **Tajawal** font.
- **Dynamic Game Flow**: Supports 2 to 10 players over 6 rounds of interactive play.
- **Helps System (مساعدات)**:
  - **حذف خيارين**: Remove two wrong answers from multiple-choice questions.
  - **عرض الخيارات**: Convert an open question into a multiple-choice question.
- **Real-time Scoreboard**: Keep track of all players' points throughout the session.
- **Premium Design**: Desert-inspired color palette (#C9A84C Gold, #F5F0E8 Sand) with subtle geometric patterns.

## 🛠 Technical Specifications

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (iOS 17+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **UI/UX**: Custom Canvas-based spinning wheel, Haptic feedback, and Sound effect stubs.
- **Data**: Questions loaded from a local `questions.json` file for easy expandability.

## 📁 Project Structure

```
QuizUAE/
├── App/
│   └── QuizUAEApp.swift       # Entry point and navigation
├── Models/
│   ├── Player.swift           # Player data model
│   ├── Question.swift         # Question data model
│   └── GameSession.swift      # Session state and GameState enum
├── ViewModels/
│   └── GameViewModel.swift    # Core game logic and state management
├── Views/
│   ├── HomeView.swift         # Branded landing screen
│   ├── SetupView.swift        # Player registration
│   ├── GameView.swift         # Main turn container & Scoreboard
│   ├── WheelView.swift        # Interactive spinning wheel
│   ├── QuestionView.swift     # Question display and answer logic
│   └── ResultsView.swift      # Final rankings and winner screen
├── Resources/
│   └── questions.json         # Hardcoded question bank
└── Utils/
    ├── Extensions.swift       # Color palette and theme helpers
    └── Managers.swift         # Sound and Haptic feedback stubs
```

## 🚀 Getting Started

1. Open the project in Xcode 15+.
2. Ensure the deployment target is set to iOS 17.0 or higher.
3. Build and Run on a simulator or physical device.
4. Enjoy the heritage experience!

## 🇦🇪 Question Categories

- 🏛️ UAE History & Founding
- 🗺️ Geography & Landmarks
- 🦅 Traditions & Customs
- 🍽️ Emirati Cuisine
- 🌊 Sea & Pearling Culture
- 🗣️ Sayings & Proverbs
