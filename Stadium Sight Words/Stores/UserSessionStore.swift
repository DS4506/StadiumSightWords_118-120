
import Foundation
import Combine

final class UserSessionsStore: ObservableObject {

    private let nameKey = "ssw.user.displayName"
    private let loggedKey = "ssw.user.isLoggedIn"
    private let lastLoginKey = "ssw.user.lastLogin"

    @Published var displayName: String {
        didSet { save() }
    }

    @Published var isLoggedIn: Bool {
        didSet { save() }
    }

    @Published var lastLogin: Date? {
        didSet { save() }
    }

    init() {
        self.displayName = UserDefaults.standard.string(forKey: nameKey) ?? "Player"
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedKey)

        if let time = UserDefaults.standard.object(forKey: lastLoginKey) as? TimeInterval {
            self.lastLogin = Date(timeIntervalSince1970: time)
        } else {
            self.lastLogin = nil
        }
    }

    func login(name: String) {
        displayName = name
        isLoggedIn = true
        lastLogin = Date()
    }

    func logout() {
        isLoggedIn = false
    }

    private func save() {
        UserDefaults.standard.set(displayName, forKey: nameKey)
        UserDefaults.standard.set(isLoggedIn, forKey: loggedKey)

        if let lastLogin {
            UserDefaults.standard.set(lastLogin.timeIntervalSince1970, forKey: lastLoginKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lastLoginKey)
        }
    }
}
