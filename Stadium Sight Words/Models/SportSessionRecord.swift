
import Foundation

struct SportSessionRecord: Codable, Identifiable {
    let id: UUID
    let sport: SportType
    let date: Date

    // Snapshot from a finished session
    let score: Int
    let totalAnswered: Int
    let correctCount: Int
    let incorrectCount: Int
    let accuracyPercent: Int
    let bestStreak: Int

    init(
        id: UUID = UUID(),
        sport: SportType,
        date: Date = Date(),
        score: Int,
        totalAnswered: Int,
        correctCount: Int,
        incorrectCount: Int,
        accuracyPercent: Int,
        bestStreak: Int
    ) {
        self.id = id
        self.sport = sport
        self.date = date
        self.score = score
        self.totalAnswered = totalAnswered
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
        self.accuracyPercent = accuracyPercent
        self.bestStreak = bestStreak
    }
}
