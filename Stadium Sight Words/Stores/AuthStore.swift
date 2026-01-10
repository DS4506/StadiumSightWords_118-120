
import Foundation
import Combine

final class AuthStore: ObservableObject {

    @Published private(set) var isLoggedIn: Bool
    @Published private(set) var currentUsername: String

    // Keys
    private let defaultsLoggedInKey = "ssw.auth.loggedIn"
    private let defaultsUsernameKey = "ssw.auth.username"
    private let defaultsRegisteredKey = "ssw.auth.registeredUsername"

    // Keychain
    private let keychainServiceName = "ssw.auth.password"

    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: defaultsLoggedInKey)
        self.currentUsername = UserDefaults.standard.string(forKey: defaultsUsernameKey) ?? ""
    }

    var registeredUsername: String? {
        UserDefaults.standard.string(forKey: defaultsRegisteredKey)
    }

    var hasRegisteredAccount: Bool {
        registeredUsername != nil
    }

    func register(username: String, password: String) -> (success: Bool, message: String) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard u.count >= 3 else { return (false, "Username must be at least 3 characters.") }
        guard p.count >= 4 else { return (false, "Password must be at least 4 characters.") }

        // Save username as the one account on device
        UserDefaults.standard.set(u, forKey: defaultsRegisteredKey)

        // Save password securely in Keychain using the username as account key
        let ok = KeychainService.save(p, service: keychainServiceName, account: u)
        guard ok else { return (false, "Could not save password securely. Try again.") }

        // Log in
        setLoggedIn(username: u, loggedIn: true)
        return (true, "Account created.")
    }

    func login(username: String, password: String) -> (success: Bool, message: String) {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let registered = registeredUsername else {
            return (false, "No account found. Create one first.")
        }

        guard u == registered else { return (false, "Username not found on this device.") }

        guard let savedPassword = KeychainService.read(service: keychainServiceName, account: u) else {
            return (false, "Password not available. Recreate the account.")
        }

        guard p == savedPassword else {
            return (false, "Incorrect password.")
        }

        setLoggedIn(username: u, loggedIn: true)
        return (true, "Signed in.")
    }

    func logout() {
        setLoggedIn(username: "", loggedIn: false)
    }

    private func setLoggedIn(username: String, loggedIn: Bool) {
        currentUsername = username
        isLoggedIn = loggedIn
        UserDefaults.standard.set(loggedIn, forKey: defaultsLoggedInKey)
        UserDefaults.standard.set(username, forKey: defaultsUsernameKey)
    }
}
