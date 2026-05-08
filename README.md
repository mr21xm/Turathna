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

## 🚀 How to Run the App (Beginner's Guide)

Since this is a fresh SwiftUI project, follow these exact steps to run "تراثنا" on your Mac using Xcode:

### 1. Create a new Xcode Project
- Open **Xcode**.
- Select **File > New > Project**.
- Choose **iOS** as the platform and **App** as the template.
- Click **Next**.
- **Product Name**: `QuizUAE` (Internal project name).
- **Interface**: SwiftUI.
- **Language**: Swift.
- Click **Next** and save the project to your computer.

### 2. Add the Code Files
You need to create the folders and files to match the project structure:
- In the Xcode sidebar (Project Navigator), right-click the `QuizUAE` folder.
- Select **New Group** to create folders: `App`, `Models`, `ViewModels`, `Views`, `Resources`, `Utils`.
- Right-click each folder, select **New File > Swift File**, and name them exactly as shown in the project structure (e.g., `Player.swift`, `GameViewModel.swift`).
- **Copy and Paste** the code I provided for each file into its corresponding file in Xcode.
- **Note**: For `QuizUAEApp.swift`, replace the default code entirely.

### 3. Add the Question Bank
- Right-click the `Resources` folder in Xcode.
- Select **New File > Empty** (under the Resource tab) and name it `questions.json`.
- **Copy and Paste** the JSON question data into this file.

### 4. Setup the Font (Tajawal)
- Download the **Tajawal** font from [Google Fonts](https://fonts.google.com/specimen/Tajawal).
- Drag the `.ttf` files into the `Resources/Fonts` folder in your Xcode project.
- Select "Copy items if needed" and ensure your app target is checked.
- In Xcode, click on your project at the very top of the sidebar.
- Go to the **Info** tab.
- Add a new row: `Fonts provided by application`.
- List the filenames of the Tajawal fonts (e.g., `Tajawal-Regular.ttf`, `Tajawal-Bold.ttf`).

### 5. Run the App
- At the very top of the Xcode window, select a simulator (e.g., **iPhone 15 Pro**).
- Click the **Play button** (Triangle) in the top-left corner.
- The simulator will boot up, and "تراثنا" will launch!

## 🇦🇪 Question Categories

- 🏛️ UAE History & Founding
- 🗺️ Geography & Landmarks
- 🦅 Traditions & Customs
- 🍽️ Emirati Cuisine
- 🌊 Sea & Pearling Culture
- 🗣️ Sayings & Proverbs
