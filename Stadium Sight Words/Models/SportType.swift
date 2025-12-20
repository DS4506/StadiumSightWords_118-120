
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

    // Your Assets.xcassets image names (must match exactly)
    var assetIconName: String {
        switch self {
        case .soccer: return "soccer_icon"
        case .basketball: return "basketball_icon"
        case .football: return "football_icon"
        }
    }

    // Optional: SF Symbols fallback (if you ever need it)
    var iconName: String {
        switch self {
        case .soccer: return "sportscourt"
        case .basketball: return "circle.grid.cross"
        case .football: return "shield"
        }
    }
}
