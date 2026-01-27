
import SwiftUI
import CoreData
import AVFoundation
import AudioToolbox

struct PracticeView: View {
    let sport: SportType

    @EnvironmentObject private var viewModel: SightWordsViewModel
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var queue: [SightWordRound] = []
    @State private var currentIndex: Int = 0

    @State private var isPromptVisible: Bool = false
    @State private var isLocked: Bool = true
    @State private var didStart: Bool = false

    @State private var confettiTrigger: Int = 0
    @State private var showSummary: Bool = false

    @State private var selectedOption: String? = nil

    private let synthesizer = AVSpeechSynthesizer()

    private var promptVisibleSeconds: Double { settings.difficulty.secondsVisible }

    // Replay rule: wrong words get re-added later in the same session
    private let replayDelayInsertOffset: Int = 3
    private let maxReplaysPerWord: Int = 2
    @State private var replayCount: [UUID: Int] = [:]

    private var currentRound: SightWordRound? {
        guard currentIndex >= 0, currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    var body: some View {
        ZStack {
            SportBackgroundView(sport: sport).ignoresSafeArea()
            ConfettiBurstView(trigger: confettiTrigger).ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 16) {
                header

                if let round = currentRound {
                    promptCard(round: round)
                        .padding(.horizontal, 18)

                    optionsGrid(round: round)
                        .padding(.horizontal, 18)

                    Spacer(minLength: 0)
                } else {
                    Text("Loading…")
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            .padding(.top, 12)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { Button("Back") { dismiss() } }
            ToolbarItem(placement: .topBarTrailing) { Button("End") { endSession() } }
        }
        .onAppear {
            if !didStart {
                didStart = true
                startSessionAfterScreenShows()
            }
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
                    restartSession()
                }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("\(sport.displayName) Practice")
                .font(.title2.weight(.heavy))
                .foregroundColor(.white)

            Text("Difficulty: \(settings.difficulty.displayName) (\(promptVisibleSeconds, specifier: "%.1f")s)")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
    }

    private func promptCard(round: SightWordRound) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22).fill(.white.opacity(0.18))
            VStack(spacing: 10) {
                Text(isPromptVisible ? round.promptWord : " ")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(isPromptVisible ? 1 : 0)
                Text(isLocked ? "Get ready…" : "Pick it from memory!")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.subheadline.weight(.semibold))
            }
            .padding()
        }
        .frame(height: 150)
    }

    private func optionsGrid(round: SightWordRound) -> some View {
        let cols = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(round.options, id: \.self) { option in
                Button {
                    choose(option, round: round)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.92))
                        Text(option)
                            .font(.title3.weight(.heavy))
                            .foregroundColor(.black.opacity(0.85))
                    }
                    .frame(height: 78)
                }
                .disabled(isLocked || selectedOption != nil)
            }
        }
    }

    // MARK: - Session Start

    private func startSessionAfterScreenShows() {
        viewModel.resetSession()

        let rounds = viewModel.rounds(for: sport).shuffled()
        queue = rounds

        currentIndex = 0
        replayCount = [:]
        selectedOption = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            startRound()
        }
    }

    private func restartSession() {
        didStart = true
        startSessionAfterScreenShows()
    }

    private func startRound() {
        guard currentRound != nil else { endSession(); return }

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
        let u = AVSpeechUtterance(string: round.promptWord)
        u.rate = 0.48
        u.pitchMultiplier = 1.08
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(u)
    }

    // MARK: - Answer

    private func choose(_ option: String, round: SightWordRound) {
        guard !isLocked else { return }
        selectedOption = option

        let correct = viewModel.submitAnswer(option, for: round)

        // Save every attempt to Core Data
        savePracticeResult(word: round.promptWord, wasCorrect: correct)

        if correct {
            confettiTrigger += 1
            AudioServicesPlaySystemSound(1104)
        } else {
            AudioServicesPlaySystemSound(1053)
            requeueIfAllowed(round)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            advance()
        }
    }

    // Wrong answers come back later in the same session
    private func requeueIfAllowed(_ round: SightWordRound) {
        let count = replayCount[round.id, default: 0]
        guard count < maxReplaysPerWord else { return }
        replayCount[round.id] = count + 1

        let insertIndex = min(currentIndex + replayDelayInsertOffset, queue.count)
        queue.insert(round, at: insertIndex)
    }

    private func advance() {
        selectedOption = nil

        if currentIndex + 1 < queue.count {
            currentIndex += 1
            startRound()
        } else {
            endSession()
        }
    }

    // MARK: - End Session

    private func endSession() {
        saveSessionSummary()
        showSummary = true
        isLocked = true
    }

    // MARK: - Core Data Writes

    private func savePracticeResult(word: String, wasCorrect: Bool) {
        let r = PracticeResult(context: viewContext)
        r.id = UUID()
        r.sport = sport.rawValue
        r.word = word
        r.wasCorrect = wasCorrect
        r.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            print("Failed to save PracticeResult: \(error.localizedDescription)")
        }
    }

    private func saveSessionSummary() {
        let s = SessionSummary(context: viewContext)
        s.id = UUID()
        s.sport = sport.rawValue
        s.score = Int64(viewModel.score)
        s.correctCount = Int64(viewModel.correctCount)
        s.incorrectCount = Int64(viewModel.incorrectCount)
        s.accuracyPercent = Int64(viewModel.accuracyPercent)
        s.bestStreak = Int64(viewModel.bestStreak)
        s.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            print("Failed to save SessionSummary: \(error.localizedDescription)")
        }
    }
}
