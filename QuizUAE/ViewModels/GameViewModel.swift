import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .home
    @Published var session: GameSession?
    @Published var questions: [Question] = []
    @Published var currentQuestion: Question?
    @Published var wheelResult: WheelSegment?
    @Published var wheelSegments: [WheelSegment] = []

    @Published var playerNames: [String] = ["", ""]
    @Published var numberOfPlayers: Int = 2 {
        didSet {
            updatePlayerNamesCount()
        }
    }

    private var usedQuestions: Set<UUID> = []

    init() {
        loadQuestions()
        setupWheel()
    }

    private func setupWheel() {
        let baseSegments: [WheelSegment] = [
            WheelSegment(type: .points, value: 50, color: .blue, label: "50"),
            WheelSegment(type: .points, value: 100, color: .green, label: "100"),
            WheelSegment(type: .points, value: 150, color: .orange, label: "150"),
            WheelSegment(type: .points, value: 200, color: .purple, label: "200"),
            WheelSegment(type: .points, value: 250, color: .pink, label: "250"),
            WheelSegment(type: .points, value: 300, color: .cyan, label: "300"),
            WheelSegment(type: .points, value: 350, color: .indigo, label: "350"),
            WheelSegment(type: .points, value: 400, color: .teal, label: "400"),
            WheelSegment(type: .points, value: 450, color: .yellow, label: "450"),
            WheelSegment(type: .points, value: 500, color: .brown, label: "500"),
            WheelSegment(type: .jackpot, value: 1000, color: .primaryGold, label: "1000"),
            WheelSegment(type: .jackpot, value: 1200, color: Color(hex: "#FFD700"), label: "1200"),
            WheelSegment(type: .iflas, value: 0, color: .errorRed, label: "إفلاس"),
            WheelSegment(type: .iflas, value: 0, color: .errorRed, label: "إفلاس"),
            WheelSegment(type: .skipTurn, value: 0, color: .gray, label: "راحت عليك"),
            WheelSegment(type: .skipTurn, value: 0, color: .gray, label: "راحت عليك")
        ]
        self.wheelSegments = baseSegments.shuffled()
    }

    private func loadQuestions() {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                self.questions = try JSONDecoder().decode([Question].self, data)
            } catch {
                print("Error loading questions: \(error)")
            }
        }
    }

    private func updatePlayerNamesCount() {
        if playerNames.count < numberOfPlayers {
            for _ in 0..<(numberOfPlayers - playerNames.count) {
                playerNames.append("")
            }
        } else if playerNames.count > numberOfPlayers {
            playerNames = Array(playerNames.prefix(numberOfPlayers))
        }
    }

    func startGame() {
        let players = playerNames.filter { !$0.isEmpty }.map { Player(id: UUID(), name: $0) }
        guard players.count >= 2 else { return }

        session = GameSession(players: players.shuffled())
        gameState = .playing
    }

    func spinWheel() {
        gameState = .spinning
        // The actual spinning logic will be in the WheelView/WheelViewModel
        // which will call back to landOnSegment(_:)
    }

    func landOnSegment(_ segment: WheelSegment) {
        wheelResult = segment

        switch segment.type {
        case .points, .jackpot:
            serveQuestion()
        case .iflas:
            resetCurrentPlayerScore()
            nextTurn()
        case .skipTurn:
            nextTurn()
        }
    }

    private func serveQuestion() {
        let availableQuestions = questions.filter { !usedQuestions.contains($0.id) }
        if let question = availableQuestions.randomElement() {
            currentQuestion = question
            usedQuestions.insert(question.id)
            gameState = .question
        } else {
            // Out of questions, maybe reshuffle or end game?
            // For now, reset usedQuestions
            usedQuestions.removeAll()
            serveQuestion()
        }
    }

    func submitAnswer(_ isCorrect: Bool) {
        guard let session = session, let wheelResult = wheelResult else { return }

        if isCorrect {
            self.session?.players[session.currentPlayerIndex].score += wheelResult.value
        }

        // Reset turn-specific help usage
        self.session?.players[session.currentPlayerIndex].hasUsedHelpThisTurn = false

        nextTurn()
    }

    func useHelp(_ type: HelpType) {
        guard var session = session else { return }
        let player = session.currentPlayer

        if player.hasUsedHelpThisTurn { return }

        switch type {
        case .removeTwo:
            if !player.usedHelpRemoveTwo && currentQuestion?.type == .multipleChoice {
                self.session?.players[session.currentPlayerIndex].usedHelpRemoveTwo = true
                self.session?.players[session.currentPlayerIndex].hasUsedHelpThisTurn = true
                // Logic to remove options will be in the View
            }
        case .showOptions:
            if !player.usedHelpShowOptions && currentQuestion?.type == .open {
                self.session?.players[session.currentPlayerIndex].usedHelpShowOptions = true
                self.session?.players[session.currentPlayerIndex].hasUsedHelpThisTurn = true
                // Logic to convert open to MC will be in the View/Model
                convertToMultipleChoice()
            }
        }
    }

    private func convertToMultipleChoice() {
        guard let current = currentQuestion, current.type == .open else { return }
        // Find a MC question or generate random choices?
        // For simplicity, let's find a MC question with the same answer or similar category
        // In a real app, you'd have choices prepared for all questions or a generator.
        // Let's assume for now we provide some default choices if none exist.

        let dummyChoices = [current.correctAnswer, "خيار 2", "خيار 3", "خيار 4"].shuffled()
        currentQuestion = Question(
            id: current.id,
            text: current.text,
            type: .multipleChoice,
            choices: dummyChoices,
            correctAnswer: current.correctAnswer,
            category: current.category,
            difficulty: current.difficulty
        )
    }

    private func resetCurrentPlayerScore() {
        guard let session = session else { return }
        self.session?.players[session.currentPlayerIndex].score = 0
    }

    private func nextTurn() {
        guard var session = session else { return }

        var nextPlayerIndex = session.currentPlayerIndex + 1
        var nextRound = session.currentRound

        if nextPlayerIndex >= session.players.count {
            nextPlayerIndex = 0
            nextRound += 1
        }

        if nextRound > session.totalRounds {
            gameState = .results
        } else {
            self.session?.currentPlayerIndex = nextPlayerIndex
            self.session?.currentRound = nextRound
            gameState = .playing
        }

        wheelResult = nil
        currentQuestion = nil
    }

    func playAgain() {
        usedQuestions.removeAll()
        gameState = .setup
        session = nil
    }
}

enum HelpType {
    case removeTwo
    case showOptions
}

struct WheelSegment: Identifiable, Equatable {
    let id = UUID()
    let type: SegmentType
    let value: Int
    let color: Color
    let label: String
}

enum SegmentType {
    case points
    case jackpot
    case iflas
    case skipTurn
}
