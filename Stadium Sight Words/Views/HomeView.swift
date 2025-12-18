
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: SightWordsViewModel

    var body: some View {
        NavigationView {
            ZStack {
                KidStadiumBackground()

                VStack(spacing: 18) {

                    VStack(spacing: 6) {
                        Text("Stadium Sight Words")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)

                        Text("Pick a sport and score points by reading!")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 10)

                    VStack(spacing: 14) {
                        sportLink(title: "Soccer Practice", iconAssetName: "soccer_icon", sport: .soccer)
                        sportLink(title: "Basketball Practice", iconAssetName: "basketball_icon", sport: .basketball)
                        sportLink(title: "Football Practice", iconAssetName: "football_icon", sport: .football)
                    }
                    .padding(.top, 6)

                    Spacer(minLength: 0)

                    Text("Tip: Short sessions win. 5 minutes is plenty.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.bottom, 10)
                }
                .padding()
                .frame(maxWidth: 620) // keeps iPad from looking too stretched
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func sportLink(title: String, iconAssetName: String, sport: SportType) -> some View {
        NavigationLink(destination: PracticeView(sport: sport)) {
            HStack(spacing: 14) {
                Image(iconAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .padding(.leading, 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black.opacity(0.85))

                    Text("Tap to start")
                        .font(.subheadline)
                        .foregroundColor(Color.black.opacity(0.55))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(Color.black.opacity(0.35))
                    .padding(.trailing, 6)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.92))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct KidStadiumBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.35, green: 0.75, blue: 1.00),  // sky blue
                Color(red: 0.63, green: 0.45, blue: 1.00),  // purple pop
                Color(red: 1.00, green: 0.55, blue: 0.55)   // warm glow
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        // soft “stadium lights” glow
        RadialGradient(
            colors: [Color.white.opacity(0.22), Color.clear],
            center: .top,
            startRadius: 10,
            endRadius: 420
        )
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
        .environmentObject(SightWordsViewModel())
}
