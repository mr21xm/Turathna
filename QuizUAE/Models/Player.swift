import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var score: Int = 0
    var usedHelpRemoveTwo: Bool = false
    var usedHelpShowOptions: Bool = false

    var hasUsedHelpThisTurn: Bool = false // Reset each turn
}
