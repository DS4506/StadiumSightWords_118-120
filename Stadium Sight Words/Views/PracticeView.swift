
import SwiftUI
import AVFoundation
import AudioToolbox

struct PracticeView: View {
    let sport: SportType

    @EnvironmentObject private var viewModel: SightWordsViewModel
    @EnvironmentObject private var scoreStore: ScoreStore
    @Environment(\.dismiss) private var dismiss

    @State private var sportRounds: [SightWordRound] = []
    @State private var currentIndex: Int = 0

    // Memory mode
    @State private var isPromptVisible: Bool = true
    @State private var isLocked: Bool = true
    private let promptVisibleSeconds: Double = 1.5

    // Confetti trigger (increment to re-fire)
    @State private var confettiTrigger: Int = 0

    // End-of-session summary
    @State private var showSummary: Bool = false

    // Selection (lock after tap until next round)
    @State private var selectedOption: String? = nil

    // Text-to-speech
    private let synthesizer = AVSpeechSynthesizer()

    private let nextRoundDelay: Double = 0.7

    private var currentRound: SightWordRound? {
        guard currentIndex >= 0, currentIndex < sportRounds.count else { return nil }
        return sportRounds[currentIndex]
    }

    private var roundNumberText: String {
        let total = max(sportRounds.count, 1)
        return "\(min(currentIndex + 1, total)) / \(total)"
    }

    var body: some View {
        ZStack {
            // If your project uses SportBackgroundView, keep this.
            // If not, replace with your background view.
            SportBackgroundView(sport: sport)
                .ignoresSafeArea()

            // Your ConfettiBurstView signature is trigger-only
            ConfettiBurstView(trigger: confettiTrigger)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 16) {
                header

                if let round = currentRound {
                    promptCard(round: round)
                        .padding(.horizontal, 18)

                    optionsGrid(round: round)
                        .padding(.horizontal, 18)

                    Spacer(minLength: 0)
                } else {
                    VStack(spacing: 12) {
                        Text("No rounds found")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Text("Check that SightWords.json has \(sport.displayName) rounds.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                }
            }
            .padding(.top, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("End") { endSessionAndShowSummary() }
            }
        }
        .onAppear {
            startSession()
        }
        .sheet(isPresented: $showSummary) {
            // ✅ FIX: pass sport: sport
            ParentSessionSummaryView(
                sport: sport,
                score: viewModel.score,
                totalAnswered: viewModel.totalAnswered,
                correctCount: viewModel.correctCount,
                incorrectCount: viewModel.incorrectCount,
                accuracyPercent: viewModel.accuracyPercent,
                bestStreak: viewModel.bestStreak,
                onStartNewSession: {
                    startSession()
                    showSummary = false
                }
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Text("\(sport.displayName) Practice")
                .font(.title2.weight(.heavy))
                .foregroundStyle(.white)
                .shadow(radius: 8)

            HStack(spacing: 10) {
                statPill(title: "Score", value: "\(viewModel.score)")
                statPill(title: "Streak", value: "\(viewModel.streak)")
                statPill(title: "Round", value: roundNumberText)

                Button {
                    speakCurrentWord()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.16), in: Circle())
                }
                .accessibilityLabel("Hear the word")
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .opacity(0.9)
            Text(value)
                .font(.headline.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Prompt

    private func promptCard(round: SightWordRound) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Text("Memorize the word")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))

                ZStack {
                    Text(round.promptWord)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(isPromptVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: isPromptVisible)

                    Text("...")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .opacity(isPromptVisible ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: isPromptVisible)
                }

                Text(isLocked ? "Watch and listen!" : "Now pick it from memory!")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Options

    private func optionsGrid(round: SightWordRound) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(round.options, id: \.self) { option in
                Button {
                    choose(option, round: round)
                } label: {
                    optionTile(title: option, isSelected: selectedOption == option, correctness: correctnessForOption(option))
                }
                .disabled(isLocked || selectedOption != nil)
            }
        }
    }

    private func optionTile(title: String, isSelected: Bool, correctness: Bool?) -> some View {
        let bg: AnyShapeStyle = {
            if let correctness {
                return correctness ? AnyShapeStyle(Color.green.opacity(0.75))
                                 : AnyShapeStyle(Color.red.opacity(0.75))
            }
            return AnyShapeStyle(Color.white.opacity(0.92))
        }()

        let fg: Color = (correctness == nil) ? .black.opacity(0.85) : .white

        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.black.opacity(0.08), lineWidth: 1)
                )

            Text(title)
                .font(.title3.weight(.heavy))
                .foregroundStyle(fg)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.horizontal, 10)
        }
        .frame(height: 78)
        .scaleEffect(isSelected ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.78), value: isSelected)
    }

    private func correctnessForOption(_ option: String) -> Bool? {
        guard selectedOption != nil else { return nil }
        guard let round = currentRound else { return nil }
        if option == round.correctWord { return true }
        if option == selectedOption { return false }
        return nil
    }

    // MARK: - Flow

    private func startSession() {
        viewModel.resetSession()
        sportRounds = viewModel.rounds(for: sport).shuffled()
        currentIndex = 0
        selectedOption = nil
        startMemoryTimerForCurrentRound()
    }

    private func startMemoryTimerForCurrentRound() {
        guard currentRound != nil else { return }

        isLocked = true
        isPromptVisible = true
        selectedOption = nil

        speakCurrentWord()

        DispatchQueue.main.asyncAfter(deadline: .now() + promptVisibleSeconds) {
            withAnimation(.easeInOut(duration: 0.25)) {
                isPromptVisible = false
            }
            isLocked = false
        }
    }

    private func speakCurrentWord() {
        guard let round = currentRound else { return }

        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: round.promptWord)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.08
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        synthesizer.speak(utterance)
    }

    private func choose(_ option: String, round: SightWordRound) {
        guard !isLocked else { return }

        selectedOption = option
        let correct = viewModel.submitAnswer(option, for: round)

        if correct {
            AudioServicesPlaySystemSound(1104)
            confettiTrigger += 1
        } else {
            AudioServicesPlaySystemSound(1053)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + nextRoundDelay) {
            goToNextRoundOrEnd()
        }
    }

    private func goToNextRoundOrEnd() {
        selectedOption = nil

        if currentIndex + 1 < sportRounds.count {
            currentIndex += 1
            startMemoryTimerForCurrentRound()
        } else {
            endSessionAndShowSummary()
        }
    }

    private func endSessionAndShowSummary() {
        saveSessionToHistory()
        showSummary = true
        isLocked = true
    }

    private func saveSessionToHistory() {
        let record = SportSessionRecord(
            sport: sport,
            score: viewModel.score,
            totalAnswered: viewModel.totalAnswered,
            correctCount: viewModel.correctCount,
            incorrectCount: viewModel.incorrectCount,
            accuracyPercent: viewModel.accuracyPercent,
            bestStreak: viewModel.bestStreak
        )
        scoreStore.addSession(record)
    }
}
