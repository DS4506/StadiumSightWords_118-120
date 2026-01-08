
import SwiftUI

@main
struct Stadium_Sight_WordsApp: App {

    @StateObject private var viewModel = SightWordsViewModel()
    @StateObject private var userSessionsStore = UserSessionsStore()
    @StateObject private var scoreStore = ScoreStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .environmentObject(userSessionsStore)
                .environmentObject(scoreStore)
        }
    }
}
