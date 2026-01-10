
import SwiftUI

@main
struct Stadium_Sight_WordsApp: App {

    @StateObject private var viewModel = SightWordsViewModel()
    @StateObject private var userSessionsStore = UserSessionsStore()
    @StateObject private var scoreStore = ScoreStore()
    @StateObject private var authStore = AuthStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .environmentObject(userSessionsStore)
                .environmentObject(scoreStore)
                .environmentObject(authStore)
        }
    }
}
