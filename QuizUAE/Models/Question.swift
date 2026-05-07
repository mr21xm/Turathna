import Foundation

enum QuestionType: String, Codable {
    case multipleChoice
    case open
}

enum Difficulty: String, Codable {
    case easy
    case medium
    case hard
}

struct Question: Identifiable, Codable {
    let id: UUID
    let text: String
    let type: QuestionType
    let choices: [String]?
    let correctAnswer: String
    let category: String
    let difficulty: Difficulty
}
