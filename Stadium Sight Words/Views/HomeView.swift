

//  HomeView.swift
//  Stadium Sight Words
//

import SwiftUI

struct HomeView: View {

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                HomeBackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    header

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(SportType.allCases) { sport in
                            NavigationLink(destination: PracticeView(sport: sport)) {
                                SportTile(
                                    title: "\(sport.displayName) Practice",
                                    subtitle: "Tap to start",
                                    assetName: assetName(for: sport)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)

                    Spacer()

                    Text("Tip: Short sessions win. 5 minutes is plenty.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.bottom, 12)
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("Stadium")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, 8)

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
        .padding(.top, 10)
    }

    // Uses YOUR asset names from Assets.xcassets
    private func assetName(for sport: SportType) -> String {
        switch sport {
        case .soccer: return "soccer_icon"
        case .basketball: return "basketball_icon"
        case .football: return "football_icon"
        }
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
        .aspectRatio(1, contentMode: .fit) // makes each card a square
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

