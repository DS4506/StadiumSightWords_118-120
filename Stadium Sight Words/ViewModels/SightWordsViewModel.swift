
import Foundation
import Combine

final class SightWordsViewModel: ObservableObject {

    @Published var rounds: [SightWordRound] = []

    // Live session stats
    @Published var score: Int = 0
    @Published var streak: Int = 0

    // Parent-friendly summary stats
    @Published var totalAnswered: Int = 0
    @Published var correctCount: Int = 0
    @Published var incorrectCount: Int = 0
    @Published var bestStreak: Int = 0

    init() {
        loadRounds()
    }

    private func loadRounds() {
        // Matches your file name in Copy Bundle Resources: "SightWords.json"
        guard let url = Bundle.main.url(forResource: "SightWords", withExtension: "json") else {
            print("SightWords.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([SightWordRound].self, from: data)
            rounds = decoded
        } catch {
            print("Failed to load rounds: \(error)")
        }
    }

    func rounds(for sport: SportType) -> [SightWordRound] {
        rounds.filter { $0.sport == sport }
    }

    func resetSession() {
        score = 0
        streak = 0

        totalAnswered = 0
        correctCount = 0
        incorrectCount = 0
        bestStreak = 0
    }

    @discardableResult
    func submitAnswer(_ selected: String, for round: SightWordRound) -> Bool {
        totalAnswered += 1

        let isCorrect = (selected == round.correctWord)

        if isCorrect {
            score += 1
            correctCount += 1
            streak += 1
            if streak > bestStreak { bestStreak = streak }
        } else {
            incorrectCount += 1
            streak = 0
        }

        return isCorrect
    }

    var accuracyPercent: Int {
        guard totalAnswered > 0 else { return 0 }
        let pct = (Double(correctCount) / Double(totalAnswered)) * 100.0
        return Int(pct.rounded())
    }
}
