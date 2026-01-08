
import Foundation
import Combine

final class ScoreStore: ObservableObject {

    private let key = "ssw.scoreHistory"

    @Published private(set) var history: [SportSessionRecord] = [] {
        didSet { save() }
    }

    init() {
        load()
    }

    func addSession(_ record: SportSessionRecord) {
        history.insert(record, at: 0) // newest first
    }

    func sessions(for sport: SportType) -> [SportSessionRecord] {
        history.filter { $0.sport == sport }
    }

    func clearAll() {
        history = []
    }

    // MARK: - Persistence (UserDefaults)

    private func save() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("ScoreStore save error: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            history = []
            return
        }
        do {
            history = try JSONDecoder().decode([SportSessionRecord].self, from: data)
        } catch {
            print("ScoreStore load error: \(error)")
            history = []
        }
    }
}
