import SwiftUI

@main
struct QuizUAEApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

struct ContentView: View {
    @StateObject private var gameVM = GameViewModel()

    var body: some View {
        Group {
            switch gameVM.gameState {
            case .home:
                HomeView(gameVM: gameVM)
            case .setup:
                SetupView(gameVM: gameVM)
            case .playing, .spinning, .question:
                GameView(gameVM: gameVM)
            case .results:
                ResultsView(gameVM: gameVM)
            }
        }
        .animation(.default, value: gameVM.gameState)
    }
}
