
import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var vm: SightWordsViewModel
    @Environment(\.dismiss) private var dismiss

    let sport: SportType

    @State private var index: Int = 0
    @State private var showPromptWord: Bool = true
    @State private var isRevealing: Bool = true
    @State private var confettiTrigger: Int = 0

    // Memory timer (1 second)
    private let revealSeconds: Double = 1.0

    private var sportRounds: [SightWordRound] {
        vm.rounds(for: sport)
    }

    private var currentRound: SightWordRound? {
        guard index >= 0, index < sportRounds.count else { return nil }
        return sportRounds[index]
    }

    var body: some View {
        ZStack {
            // Your sport background view (already created in your project)
            SportBackgroundView(sport: sport)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                header

                statsRow

                Spacer(minLength: 10)

                promptArea

                optionsArea

                Spacer(minLength: 14)
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)

            // Confetti overlay (your ConfettiBurstView file should already exist)
            ConfettiBurstView(trigger: confettiTrigger)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.85)))
                }
            }
        }
        .onAppear {
            vm.resetSession()
            index = 0
            startRevealTimer()
        }
        .onChange(of: index) { _ in
            startRevealTimer()
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("\(sport.displayName) Practice")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(radius: 6)

            Text("Watch the word. Then pick it from memory.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
        }
        .padding(.top, 6)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statChip(title: "Score", value: "\(vm.score)")
            statChip(title: "Streak", value: "\(vm.streak)")
            statChip(title: "Round", value: "\(min(index + 1, max(sportRounds.count, 1)))")
        }
        .padding(.top, 8)
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.6))
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.8))
        }
        .frame(width: 72, height: 54)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.9)))
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
    }

    private var promptArea: some View {
        Group {
            if let round = currentRound {
                VStack(spacing: 10) {
                    Text(showPromptWord ? round.promptWord : " ")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white)
                        .shadow(radius: 8)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text(isRevealing ? "Look closely…" : "Now choose!")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.20), lineWidth: 1)
                )
            } else {
                Text("No rounds found for \(sport.displayName).")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
            }
        }
    }

    private var optionsArea: some View {
        VStack(spacing: 12) {
            if let round = currentRound {
                ForEach(round.options, id: \.self) { option in
                    Button {
                        // Only allow answering after the reveal finishes
                        guard !isRevealing else { return }

                        let correct = vm.submitAnswer(option, for: round)

                        if correct {
                            confettiTrigger += 1
                        }

                        // Move to next round
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                            nextRound()
                        }
                    } label: {
                        Text(option)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(isRevealing ? 0.55 : 0.92))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(isRevealing)
                }
            }
        }
        .padding(.top, 6)
    }

    private func startRevealTimer() {
        showPromptWord = true
        isRevealing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + revealSeconds) {
            // Hide the prompt word after 1 second
            showPromptWord = false
            isRevealing = false
        }
    }

    private func nextRound() {
        if index + 1 < sportRounds.count {
            index += 1
        } else {
            // End of rounds: you can present ParentSessionSummaryView here if you want.
            // For now, just go back to home.
            dismiss()
        }
    }
}

#Preview {
    PracticeView(sport: .soccer)
        .environmentObject(SightWordsViewModel())
}
