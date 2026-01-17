
import Foundation
import Combine

final class AuthStore: ObservableObject {

    // MARK: - Published state
    @Published private(set) var isLoggedIn: Bool
    @Published private(set) var currentUsername: String
    @Published private(set) var email: String

    // MARK: - UserDefaults keys
    private let loggedInKey = "ssw.auth.loggedIn"
    private let usernameKey = "ssw.auth.username"
    private let registeredUsernameKey = "ssw.auth.registeredUsername"
    private let emailKey = "ssw.auth.email"

    // MARK: - Keychain
    private let keychainServiceName = "ssw.auth.password"

    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        self.currentUsername = UserDefaults.standard.string(forKey: usernameKey) ?? ""
        self.email = UserDefaults.standard.string(forKey: emailKey) ?? ""
    }

    var hasRegisteredAccount: Bool {
        UserDefaults.standard.string(forKey: registeredUsernameKey) != nil
    }

    // MARK: - Register / Login / Logout

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

    // MARK: - Account Updates (for Settings screen)

    func updateEmail(newEmail: String) -> (Bool, String) {
        let e = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard e.count >= 5, e.contains("@"), e.contains(".") else {
            return (false, "Please enter a valid email.")
        }
        email = e
        UserDefaults.standard.set(e, forKey: emailKey)
        return (true, "Email updated.")
    }

    func updatePassword(currentPassword: String, newPassword: String) -> (Bool, String) {
        guard let registered = UserDefaults.standard.string(forKey: registeredUsernameKey) else {
            return (false, "No account found.")
        }

        let cur = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let newP = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard newP.count >= 4 else { return (false, "New password must be at least 4 characters.") }

        guard let saved = KeychainService.read(service: keychainServiceName, account: registered) else {
            return (false, "Password missing. Recreate the account.")
        }
        guard cur == saved else {
            return (false, "Current password is incorrect.")
        }

        let ok = KeychainService.save(newP, service: keychainServiceName, account: registered)
        return ok ? (true, "Password updated.") : (false, "Could not save new password.")
    }

    func updateUsername(currentPassword: String, newUsername: String) -> (Bool, String) {
        guard let registered = UserDefaults.standard.string(forKey: registeredUsernameKey) else {
            return (false, "No account found.")
        }

        let cur = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let newU = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)

        guard newU.count >= 3 else { return (false, "New username must be at least 3 characters.") }

        guard let saved = KeychainService.read(service: keychainServiceName, account: registered) else {
            return (false, "Password missing. Recreate the account.")
        }
        guard cur == saved else {
            return (false, "Current password is incorrect.")
        }

        // Move password entry to new account name
        let savedOk = KeychainService.save(saved, service: keychainServiceName, account: newU)
        guard savedOk else { return (false, "Could not update username.") }

        _ = KeychainService.delete(service: keychainServiceName, account: registered)

        // Update defaults + state
        UserDefaults.standard.set(newU, forKey: registeredUsernameKey)
        setLoggedIn(username: newU, loggedIn: true)

        return (true, "Username updated.")
    }

    // MARK: - Helpers

    private func setLoggedIn(username: String, loggedIn: Bool) {
        currentUsername = username
        isLoggedIn = loggedIn

        UserDefaults.standard.set(loggedIn, forKey: loggedInKey)
        UserDefaults.standard.set(username, forKey: usernameKey)

        // Keep email persisted even when logged out
        UserDefaults.standard.set(email, forKey: emailKey)
    }
}
