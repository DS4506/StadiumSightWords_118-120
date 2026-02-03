
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

    // ✅ Exactly 10 different words per session
    private let roundsPerSession: Int = 10

    @State private var queue: [SightWordRound] = []
    @State private var currentIndex: Int = 0

    @State private var isPromptVisible: Bool = false
    @State private var isLocked: Bool = true
    @State private var didStart: Bool = false
    @State private var selectedOption: String? = nil

    @State private var confettiTrigger: Int = 0
    @State private var showSummary: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private var promptVisibleSeconds: Double { settings.difficulty.secondsVisible }

    private var currentRound: SightWordRound? {
        guard currentIndex >= 0, currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    private var roundText: String {
        let total = max(queue.count, 1)
        return "\(min(currentIndex + 1, total)) / \(total)"
    }

    var body: some View {
        ZStack {
            SportBackgroundView(sport: sport)
                .ignoresSafeArea()

            ConfettiBurstView(trigger: confettiTrigger)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 14) {
                header

                if let round = currentRound {
                    promptCard(round)
                        .padding(.horizontal, 18)

                    optionsGrid(round)
                        .padding(.horizontal, 18)

                    Spacer(minLength: 0)
                } else {
                    Text("Loading…")
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            .padding(.top, 10)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("End") { endSession() }
            }
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

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("\(sport.displayName) Practice")
                .font(.title2.weight(.heavy))
                .foregroundColor(.white)

            Text("Difficulty: \(settings.difficulty.displayName) (\(promptVisibleSeconds, specifier: "%.1f")s)")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 10) {
                statPill("Score", "\(viewModel.score)")
                statPill("Streak", "\(viewModel.streak)")
                statPill("Round", roundText)

                Button {
                    speakCurrentWord()
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.white.opacity(0.16), in: Circle())
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.top, 6)
    }

    private func statPill(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Prompt

    private func promptCard(_ round: SightWordRound) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.18))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.20), lineWidth: 1))

            VStack(spacing: 10) {
                Text(isPromptVisible ? round.promptWord : " ")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(isPromptVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isPromptVisible)

                Text(isLocked ? "Get ready…" : "Pick it from memory!")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
        }
        .frame(height: 150)
    }

    // MARK: - Options

    private func optionsGrid(_ round: SightWordRound) -> some View {
        let cols = [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(round.options, id: \.self) { option in
                Button {
                    choose(option, round)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.92))
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

    // MARK: - Session Setup

    private func startSessionAfterScreenShows() {
        viewModel.resetSession()

        let allRounds = viewModel.rounds(for: sport)

        // ✅ Ensure 10 unique promptWord rounds
        queue = buildUniqueQueue(from: allRounds, count: roundsPerSession)
        currentIndex = 0
        selectedOption = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            startRound()
        }
    }

    private func restartSession() {
        didStart = true
        startSessionAfterScreenShows()
    }

    private func buildUniqueQueue(from rounds: [SightWordRound], count: Int) -> [SightWordRound] {
        // Unique by promptWord
        var seen = Set<String>()
        var uniques: [SightWordRound] = []

        for r in rounds.shuffled() {
            let key = r.promptWord.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                uniques.append(r)
            }
            if uniques.count == count { break }
        }

        // If your JSON has fewer than 10 unique words, it will return fewer.
        // But since you want 10, make sure each sport has at least 10 unique promptWord entries.
        return uniques
    }

    private func startRound() {
        guard currentRound != nil else {
            endSession()
            return
        }

        isLocked = true
        isPromptVisible = true
        selectedOption = nil

        speakCurrentWord()

        DispatchQueue.main.asyncAfter(deadline: .now() + promptVisibleSeconds) {
            withAnimation(.easeInOut(duration: 0.2)) {
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

    private func speakCelebration() {
        let phrase: String
        switch sport {
        case .soccer: phrase = "Goal!!"
        case .basketball: phrase = "Swish!"
        case .football: phrase = "Touchdown!"
        }

        let u = AVSpeechUtterance(string: phrase)
        u.rate = 0.45
        u.pitchMultiplier = 1.12
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(u)
    }

    // MARK: - Answer + Advance

    private func choose(_ option: String, _ round: SightWordRound) {
        guard !isLocked else { return }
        selectedOption = option

        let correct = viewModel.submitAnswer(option, for: round)

        // Save attempt to Core Data
        savePracticeResult(word: round.promptWord, wasCorrect: correct)

        if correct {
            confettiTrigger += 1
            AudioServicesPlaySystemSound(1104)
            speakCelebration()
        } else {
            AudioServicesPlaySystemSound(1053)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            advance()
        }
    }

    private func advance() {
        selectedOption = nil
        currentIndex += 1

        if currentIndex < queue.count {
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
