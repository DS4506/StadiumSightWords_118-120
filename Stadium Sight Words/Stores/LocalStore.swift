
import Foundation

enum LocalStore {

    static func save<T: Codable>(_ value: T, key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("LocalStore save error for \(key): \(error)")
        }
    }

    static func load<T: Codable>(_ type: T.Type, key: String, default defaultValue: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("LocalStore load error for \(key): \(error)")
            return defaultValue
        }
    }

    static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
