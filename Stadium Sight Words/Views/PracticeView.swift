
import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var viewModel: SightWordsViewModel
    let sport: SportType

    @State private var sportRounds: [SightWordRound] = []
    @State private var currentIndex: Int = 0

    @State private var showResult: Bool = false
    @State private var resultIsCorrect: Bool = false

    @State private var confettiTrigger: Int = 0
    @State private var showSummary: Bool = false

    @State private var mascotBump: Bool = false

    private let roundsPerSession: Int = 10

    var body: some View {
        ZStack {
            SportBackgroundView(sport: sport)
                .ignoresSafeArea()

            VStack(spacing: 14) {

                // Header with mascot icon + title
                HStack(spacing: 12) {
                    Image(iconAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .scaleEffect(mascotBump ? 1.12 : 1.0)
                        .animation(.spring(response: 0.22, dampingFraction: 0.45), value: mascotBump)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Stadium Sight Words")
                            .font(.title2.weight(.heavy))
                            .foregroundColor(.white)

                        Text("\(sport.displayName) Practice")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.92))
                    }

                    Spacer()
                }
                .padding(.top, 8)

                HStack(spacing: 10) {
                    StatChip(title: "Score", value: "\(viewModel.score)")
                    StatChip(title: "Streak", value: "\(viewModel.streak)")
                    StatChip(title: "Round", value: "\(roundNumberText)")
                }
                .padding(.top, 6)

                Spacer(minLength: 10)

                if let round = currentRound {
                    Text(round.promptWord)
                        .font(.system(size: 76, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.35)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.30), radius: 12, x: 0, y: 8)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach(round.options, id: \.self) { option in
                            Button {
                                handleTap(option, round: round)
                            } label: {
                                Text(option)
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(Color.black.opacity(0.85))
                                    .frame(maxWidth: .infinity, minHeight: 66)
                                    .background(.white.opacity(0.95))
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                            }
                            .buttonStyle(.plain)
                            .disabled(showResult)
                        }
                    }
                    .padding(.horizontal)

                    if showResult {
                        Text(resultIsCorrect ? "GOAL!" : "Try again")
                            .font(.headline.weight(.heavy))
                            .foregroundColor(.white)
                            .padding(.top, 6)
                            .transition(.opacity)
                    }

                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading words…")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                }

                Spacer(minLength: 10)

                Button {
                    showSummary = true
                } label: {
                    Text("End Session")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.black.opacity(0.35))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                }
                .padding(.bottom, 10)
            }
            .frame(maxWidth: 760)
            .padding()

            ConfettiBurstView(trigger: confettiTrigger)
        }
        .onAppear {
            startSession()
        }
        .sheet(isPresented: $showSummary) {
            ParentSessionSummaryView(
                sport: sport,
                score: viewModel.score,
                totalAnswered: viewModel.totalAnswered,
                correctCount: viewModel.correctCount,
                incorrectCount: viewModel.incorrectCount,
                accuracyPercent: viewModel.accuracyPercent,
                bestStreak: viewModel.bestStreak,
                onStartNewSession: {
                    showSummary = false
                    startSession()
                }
            )
        }
    }

    private func startSession() {
        viewModel.resetSession()
        sportRounds = Array(viewModel.rounds(for: sport).shuffled().prefix(roundsPerSession))
        currentIndex = 0
        showResult = false
        resultIsCorrect = false
        mascotBump = false
    }

    private func handleTap(_ option: String, round: SightWordRound) {
        let isCorrect = viewModel.submitAnswer(option, for: round)

        resultIsCorrect = isCorrect
        withAnimation(.easeInOut(duration: 0.15)) {
            showResult = true
        }

        if isCorrect {
            SoundFX.correct()
            confettiTrigger += 1

            mascotBump = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                mascotBump = false
            }
        } else {
            SoundFX.incorrect()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeInOut(duration: 0.15)) {
                showResult = false
            }

            if isCorrect {
                goNext()
            }
        }
    }

    private func goNext() {
        guard !sportRounds.isEmpty else { return }
        currentIndex += 1
        if currentIndex >= sportRounds.count {
            showSummary = true
        }
    }

    private var currentRound: SightWordRound? {
        guard !sportRounds.isEmpty else { return nil }
        guard currentIndex >= 0 && currentIndex < sportRounds.count else { return nil }
        return sportRounds[currentIndex]
    }

    private var roundNumberText: String {
        guard !sportRounds.isEmpty else { return "0" }
        return "\(min(currentIndex + 1, sportRounds.count))/\(sportRounds.count)"
    }

    private var iconAssetName: String {
        switch sport {
        case .soccer: return "soccer_icon"
        case .basketball: return "basketball_icon"
        case .football: return "football_icon"
        }
    }
}

private struct StatChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.95))
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 56)
        .background(.black.opacity(0.25))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}
