
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: SightWordsViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Kid-friendly gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.35, green: 0.70, blue: 1.00), // sky blue
                        Color(red: 0.55, green: 0.42, blue: 0.95), // purple
                        Color(red: 1.00, green: 0.62, blue: 0.55)  // peach
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle playful sparkle overlay
                SparkleOverlay()
                    .ignoresSafeArea()
                    .opacity(0.18)

                VStack(spacing: 18) {

                    // Headline area with better spacing + style
                    VStack(spacing: 10) {
                        Text("Stadium")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 6)

                        Text("Sight Words")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 6)

                        Text("Pick a sport and score points by reading!")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        ForEach(SportType.allCases) { sport in
                            NavigationLink {
                                PracticeView(sport: sport)
                                    .environmentObject(viewModel)
                            } label: {
                                SportCard(sport: sport)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 10)

                    Spacer()

                    Text("Tip: Short sessions win. 5 minutes is plenty.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.bottom, 18)
                }
                .padding(.horizontal, 18)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Sport Card

private struct SportCard: View {
    let sport: SportType
    @State private var bounce = false

    var body: some View {
        HStack(spacing: 14) {
            // Your icon images from Assets.xcassets
            Image(sport.assetIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .scaleEffect(bounce ? 1.06 : 1.00)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: bounce)
                .onAppear { bounce = true }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(sport.displayName) Practice")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))

                Text("Tap to start")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.55))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.black.opacity(0.35))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.90))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
        .contentShape(Rectangle())
        .accessibilityLabel("\(sport.displayName) Practice")
    }
}

// MARK: - Sparkle Overlay

private struct SparkleOverlay: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                    .position(x: geo.size.width * 0.18, y: geo.size.height * 0.18)

                Image(systemName: "star.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .position(x: geo.size.width * 0.85, y: geo.size.height * 0.25)

                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .position(x: geo.size.width * 0.78, y: geo.size.height * 0.12)

                Image(systemName: "sparkle")
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                    .position(x: geo.size.width * 0.20, y: geo.size.height * 0.70)

                Image(systemName: "sparkles")
                    .font(.system(size: 90))
                    .foregroundColor(.white)
                    .position(x: geo.size.width * 0.82, y: geo.size.height * 0.80)
            }
        }
    }
}
