
import Foundation

struct SightWordRound: Identifiable, Codable {
    let id: UUID
    let sport: SportType
    let promptWord: String
    let options: [String]
    let correctWord: String
}
