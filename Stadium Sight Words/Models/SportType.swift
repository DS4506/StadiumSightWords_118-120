
import Foundation

enum SportType: String, CaseIterable, Identifiable, Codable {
    case soccer
    case basketball
    case football

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .soccer: return "Soccer"
        case .basketball: return "Basketball"
        case .football: return "Football"
        }
    }

    // Safer SF Symbols (less likely to be missing)
    var iconName: String {
        switch self {
        case .soccer: return "sportscourt"
        case .basketball: return "circle.grid.cross"
        case .football: return "shield"
        }
    }
}
