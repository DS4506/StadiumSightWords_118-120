
//  HomeView.swift
//  Stadium Sight Words

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var auth: AuthStore
    @EnvironmentObject private var settings: SettingsStore

    private let spacing: CGFloat = 16
    private let sidePadding: CGFloat = 16

    @State private var showAccount: Bool = false
    @State private var showProgress: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                HomeBackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    topBar

                    header
                        .padding(.top, 6)

                    difficultySection
                        .padding(.top, 4)

                    GeometryReader { geo in
                        let tileWidth = (geo.size.width - spacing) / 2

                        VStack(spacing: spacing) {

                            HStack(spacing: spacing) {
                                NavigationLink(destination: LazyView { PracticeView(sport: .soccer) }) {
                                    SportTile(title: "Soccer Practice", subtitle: "Tap to start", assetName: "soccer_icon")
                                }
                                .buttonStyle(.plain)
                                .frame(width: tileWidth)

                                NavigationLink(destination: LazyView { PracticeView(sport: .basketball) }) {
                                    SportTile(title: "Basketball Practice", subtitle: "Tap to start", assetName: "basketball_icon")
                                }
                                .buttonStyle(.plain)
                                .frame(width: tileWidth)
                            }

                            HStack {
                                Spacer()

                                NavigationLink(destination: LazyView { PracticeView(sport: .football) }) {
                                    SportTile(title: "Football Practice", subtitle: "Tap to start", assetName: "football_icon")
                                }
                                .buttonStyle(.plain)
                                .frame(width: tileWidth)

                                Spacer()
                            }

                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .padding(.horizontal, sidePadding)
                    .padding(.top, 4)

                    Spacer()

                    Text("Tip: Easy = more time. Hard = faster memory.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.bottom, 12)
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAccount) {
                AccountView()
            }
            .sheet(isPresented: $showProgress) {
                ProgressDashboardView()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 10) {
            Text(auth.currentUsername.isEmpty ? "Player" : auth.currentUsername)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.16), in: Capsule())

            Spacer()

            Button {
                showProgress = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.25), in: Capsule())
            }

            Button {
                showAccount = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.25), in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Header (glow + sparkles + shine)

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                TitleGlowView()
                    .frame(height: 84)
                    .padding(.horizontal, 16)
                    .allowsHitTesting(false)

                // ✅ Title with a shine sweep layered on top
                ShineTitleText(
                    text: "Stadium Sight Words",
                    fontSize: 44,
                    weight: .heavy
                )
                .padding(.horizontal, 16)
            }

            Text("Pick a sport and score points by reading!")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.92))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 2)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Difficulty

    private var difficultySection: some View {
        VStack(spacing: 8) {
            Text("Difficulty")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white.opacity(0.92))
                .padding(.top, 2)

            Picker("Difficulty", selection: $settings.difficulty) {
                ForEach(Difficulty.allCases) { d in
                    Text("\(d.displayName) (\(d.secondsVisible, specifier: "%.1f")s)")
                        .tag(d)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 18)
        }
    }
}

// MARK: - Shine Title Text

private struct ShineTitleText: View {
    let text: String
    let fontSize: CGFloat
    let weight: Font.Weight

    @State private var shineX: CGFloat = -220

    var body: some View {
        // Base title
        let title = Text(text)
            .font(.system(size: fontSize, weight: weight, design: .rounded))
            .foregroundStyle(.white)
            .minimumScaleFactor(0.75)
            .lineLimit(1)

        return ZStack {
            title
                .shadow(color: .white.opacity(0.18), radius: 10, x: 0, y: 6)

            // Shine layer
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 160, height: 90)
                .rotationEffect(.degrees(18))
                .offset(x: shineX, y: 0)
                .blendMode(.screen)
                .mask(title) // shine only shows inside the text
                .allowsHitTesting(false)
        }
        .onAppear {
            // Gentle looping sweep
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                shineX = 220
            }
        }
    }
}

// MARK: - Title Glow + Sparkles

private struct TitleGlowView: View {
    @State private var pulse = false
    @State private var floatUp = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.10))
                .blur(radius: 18)
                .scaleEffect(pulse ? 1.08 : 0.98)
                .opacity(pulse ? 0.9 : 0.55)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)

            SparkleDot(size: 26, opacity: 0.35)
                .offset(x: -120, y: floatUp ? -10 : 6)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: floatUp)

            SparkleDot(size: 18, opacity: 0.28)
                .offset(x: 130, y: floatUp ? 8 : -8)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: floatUp)

            SparkleDot(size: 14, opacity: 0.22)
                .offset(x: 60, y: floatUp ? -14 : 0)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: floatUp)
        }
        .onAppear {
            pulse = true
            floatUp = true
        }
    }
}

private struct SparkleDot: View {
    let size: CGFloat
    let opacity: Double

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: size))
            .foregroundStyle(.white.opacity(opacity))
            .shadow(color: .white.opacity(0.18), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Sport Tile

private struct SportTile: View {
    let title: String
    let subtitle: String
    let assetName: String

    @State private var bounce = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

            VStack(spacing: 10) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 74, height: 74)
                    .scaleEffect(bounce ? 1.06 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.55), value: bounce)

                Text(title)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)

                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.55))
            }
            .padding(14)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            bounce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                bounce = false
            }
        }
    }
}

// MARK: - Background

private struct HomeBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.35, green: 0.52, blue: 0.96),
                Color(red: 0.50, green: 0.35, blue: 0.95),
                Color(red: 0.96, green: 0.55, blue: 0.68)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(StarsOverlay().opacity(0.25))
    }
}

private struct StarsOverlay: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkles")
                .font(.system(size: 220))
                .foregroundStyle(.white)
                .offset(x: -120, y: -120)

            Image(systemName: "sparkles")
                .font(.system(size: 180))
                .foregroundStyle(.white)
                .offset(x: 130, y: 220)

            Image(systemName: "sparkles")
                .font(.system(size: 120))
                .foregroundStyle(.white)
                .offset(x: -60, y: 260)
        }
    }
}
