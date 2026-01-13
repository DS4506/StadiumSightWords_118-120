
import Foundation
import Combine

final class AuthStore: ObservableObject {

    @Published private(set) var isLoggedIn: Bool
    @Published private(set) var currentUsername: String

    private let loggedInKey = "ssw.auth.loggedIn"
    private let usernameKey = "ssw.auth.username"
    private let registeredUsernameKey = "ssw.auth.registeredUsername"

    private let keychainServiceName = "ssw.auth.password"

    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        self.currentUsername = UserDefaults.standard.string(forKey: usernameKey) ?? ""
    }

    var hasRegisteredAccount: Bool {
        UserDefaults.standard.string(forKey: registeredUsernameKey) != nil
    }

    func register(username: String, password: String) -> (Bool, String) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard u.count >= 3 else { return (false, "Username must be at least 3 characters.") }
        guard p.count >= 4 else { return (false, "Password must be at least 4 characters.") }

        UserDefaults.standard.set(u, forKey: registeredUsernameKey)
        let ok = KeychainService.save(p, service: keychainServiceName, account: u)

        guard ok else { return (false, "Could not save password securely.") }

        setLoggedIn(username: u, loggedIn: true)
        return (true, "Account created.")
    }

    func login(username: String, password: String) -> (Bool, String) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let registered = UserDefaults.standard.string(forKey: registeredUsernameKey) else {
            return (false, "No account found. Create one first.")
        }
        guard u == registered else { return (false, "Username not found on this device.") }

        guard let savedPassword = KeychainService.read(service: keychainServiceName, account: u) else {
            return (false, "Password missing. Recreate the account.")
        }
        guard p == savedPassword else { return (false, "Incorrect password.") }

        setLoggedIn(username: u, loggedIn: true)
        return (true, "Signed in.")
    }

    func logout() {
        setLoggedIn(username: "", loggedIn: false)
    }

    private func setLoggedIn(username: String, loggedIn: Bool) {
        currentUsername = username
        isLoggedIn = loggedIn
        UserDefaults.standard.set(loggedIn, forKey: loggedInKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
    }
}
