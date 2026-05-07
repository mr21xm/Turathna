import Foundation

enum GameState {
    case home
    case setup
    case playing
    case spinning
    case question
    case results
}

struct GameSession: Codable {
    var players: [Player]
    var currentRound: Int = 1
    var currentPlayerIndex: Int = 0
    var totalRounds: Int = 6
    var isGameOver: Bool = false

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }
}
