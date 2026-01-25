
import SwiftUI
import CoreData

@main
struct Stadium_Sight_WordsApp: App {

    let persistenceController = PersistenceController.shared

    @StateObject private var viewModel = SightWordsViewModel()
    @StateObject private var userSessionsStore = UserSessionsStore()
    @StateObject private var scoreStore = ScoreStore()
    @StateObject private var authStore = AuthStore()
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(viewModel)
                .environmentObject(userSessionsStore)
                .environmentObject(scoreStore)
                .environmentObject(authStore)
                .environmentObject(settingsStore)
        }
    }
}
