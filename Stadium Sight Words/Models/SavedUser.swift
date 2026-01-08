
import Foundation

struct SavedUser: Codable, Equatable {
    var displayName: String
    var isLoggedIn: Bool
    var lastLogin: Date?
}
