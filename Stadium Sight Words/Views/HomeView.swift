
//  HomeView.swift
//  Stadium Sight Words

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var auth: AuthStore
    @EnvironmentObject private var settings: SettingsStore

    private let spacing: CGFloat = 16
    private let sidePadding: CGFloat = 16

    var body: some View {
        NavigationView {
            ZStack {
                HomeBackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    topBar
                    header
                    difficultyPicker

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
                    .padding(.top, 6)

                    Spacer()

                    Text("Tip: Easy = more time. Hard = faster memory.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.bottom, 12)
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Text(auth.currentUsername.isEmpty ? "Player" : auth.currentUsername)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.16), in: Capsule())

            Spacer()

            Button {
                auth.logout()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.25), in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Text("Stadium")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, 4)

            Text("Sight Words")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("Pick a sport and score points by reading!")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: - Difficulty Picker

    private var difficultyPicker: some View {
        VStack(spacing: 8) {
            Text("Difficulty")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white.opacity(0.9))

            Picker("Difficulty", selection: $settings.difficulty) {
                ForEach(Difficulty.allCases) { d in
                    Text("\(d.displayName) (\(d.secondsVisible, specifier: "%.1f")s)")
                        .tag(d)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 18)
        }
        .padding(.top, 2)
    }
}

// MARK: - Square tile

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
