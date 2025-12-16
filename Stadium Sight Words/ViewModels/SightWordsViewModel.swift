
import Foundation
import Combine

final class SightWordsViewModel: ObservableObject {

    @Published var rounds: [SightWordRound] = []

    @Published var score: Int = 0
    @Published var streak: Int = 0

    init() {
        loadRounds()
    }

    private func loadRounds() {
        // IMPORTANT:
        // Your file in Build Phases is named "SightWords.json"
        // so we must use that exact capitalization here.
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
    }

    @discardableResult
    func submitAnswer(_ selected: String, for round: SightWordRound) -> Bool {
        let isCorrect = (selected == round.correctWord)

        if isCorrect {
            score += 1
            streak += 1
        } else {
            streak = 0
        }

        return isCorrect
    }
}
