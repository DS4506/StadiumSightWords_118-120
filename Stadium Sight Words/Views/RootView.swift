
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthStore

    var body: some View {
        if auth.isLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}
