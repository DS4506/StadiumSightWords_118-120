
import Foundation
import Combine

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case normal
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }

    var secondsVisible: Double {
        switch self {
        case .easy: return 2.5
        case .normal: return 1.5
        case .hard: return 1.0
        }
    }
}

final class SettingsStore: ObservableObject {
    @Published var difficulty: Difficulty {
        didSet { save() }
    }

    private let key = "ssw.settings.difficulty"

    init() {
        if let raw = UserDefaults.standard.string(forKey: key),
           let d = Difficulty(rawValue: raw) {
            self.difficulty = d
        } else {
            self.difficulty = .normal
        }
    }

    private func save() {
        UserDefaults.standard.set(difficulty.rawValue, forKey: key)
    }
}
