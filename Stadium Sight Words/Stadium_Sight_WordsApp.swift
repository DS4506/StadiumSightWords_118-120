
import SwiftUI

@main
struct StadiumSightWordsApp: App {
    @StateObject private var viewModel = SightWordsViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
