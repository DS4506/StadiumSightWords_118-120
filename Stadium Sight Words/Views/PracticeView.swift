
import SwiftUI
import CoreData
import AVFoundation
import AudioToolbox
import UIKit

struct PracticeView: View {
    let sport: SportType

    @EnvironmentObject private var viewModel: SightWordsViewModel
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Session Phases
    private enum Phase {
        case pick
        case spell

        var label: String {
            switch self {
            case .pick: return "Pick"
            case .spell: return "Spell"
            }
        }
    }

    private let pickRoundsPerSession: Int = 10
    private let spellRoundsPerSession: Int = 5

    @State private var phase: Phase = .pick

    // Pools
    @State private var pool: [SightWordRound] = []
    @State private var pickQueue: [SightWordRound] = []
    @State private var spellQueue: [SightWordRound] = []

    // Indexing
    @State private var pickIndex: Int = 0
    @State private var spellIndex: Int = 0

    // Memory mode
    @State private var isPromptVisible: Bool = false
    @State private var isLocked: Bool = true
    @State private var didStart: Bool = false

    // Selection / Input
    @State private var selectedOption: String? = nil
    @State private var typedSpelling: String = ""
    @State private var feedbackText: String = ""

    // ✅ 2x2 grid slots: 3 words + 1 blank (blank spot changes each round)
    @State private var gridSlots: [String?] = [nil, nil, nil, nil]

    // Effects
    @State private var confettiTrigger: Int = 0
    @State private var showSummary: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private var promptVisibleSeconds: Double { settings.difficulty.secondsVisible }

    // MARK: - Current Round Helpers
    private var currentRound: SightWordRound? {
        switch phase {
        case .pick:
            guard pickIndex >= 0, pickIndex < pickQueue.count else { return nil }
            return pickQueue[pickIndex]
        case .spell:
            guard spellIndex >= 0, spellIndex < spellQueue.count else { return nil }
            return spellQueue[spellIndex]
        }
    }

    private var progressText: String {
        switch phase {
        case .pick:
            let current = min(pickIndex + 1, max(pickQueue.count, 1))
            return "\(current)/\(pickRoundsPerSession)"
        case .spell:
            let current = min(spellIndex + 1, max(spellQueue.count, 1))
            return "\(current)/\(spellRoundsPerSession)"
        }
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

                    if phase == .pick {
                        optionsGrid(round)
                            .padding(.horizontal, 18)
                    } else {
                        spellingPanel(round)
                            .padding(.horizontal, 18)
                    }

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

            HStack(spacing: 8) {
                Text("Mode: \(phase.label)")
                    .font(.footnote.weight(.bold))
                    .foregroundColor(.white.opacity(0.92))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.22), in: Capsule())

                Text("Difficulty: \(settings.difficulty.displayName) (\(promptVisibleSeconds, specifier: "%.1f")s)")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 10) {
                statPill("Score", "\(viewModel.score)")
                statPill("Streak", "\(viewModel.streak)")
                statPill("Round", progressText)

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

    // MARK: - Prompt Card

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

                Text(isLocked ? "Get ready…" : (phase == .pick ? "Pick it from memory!" : "Type the spelling from memory!"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
        }
        .frame(height: 150)
    }

    // MARK: - Pick Mode UI (true 2x2 positions)

    private func optionsGrid(_ round: SightWordRound) -> some View {
        let cols = [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(0..<4, id: \.self) { i in
                if let option = gridSlots[i] {
                    Button {
                        choosePick(option, round)
                    } label: {
                        optionTile(option)
                    }
                    .disabled(isLocked || selectedOption != nil)
                } else {
                    // Blank space that moves around
                    Color.clear
                        .frame(height: 78)
                }
            }
        }
    }

    private func optionTile(_ option: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.92))
            Text(option)
                .font(.title3.weight(.heavy))
                .foregroundColor(.black.opacity(0.85))
        }
        .frame(height: 78)
    }

    // MARK: - Spell Mode UI

    private func spellingPanel(_ round: SightWordRound) -> some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.92))

                HStack(spacing: 10) {
                    TextField("Type the word", text: $typedSpelling)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .font(.title3.weight(.heavy))
                        .foregroundColor(.black.opacity(0.85))
                        .padding(.horizontal, 12)
                        .disabled(isLocked)

                    Button {
                        submitSpelling(round)
                    } label: {
                        Text("Check")
                            .font(.headline.weight(.heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.85), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLocked || typedSpelling.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.trailing, 10)
                }
            }
            .frame(height: 78)

            if !feedbackText.isEmpty {
                Text(feedbackText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - Session Setup

    private func startSessionAfterScreenShows() {
        viewModel.resetSession()
        feedbackText = ""
        typedSpelling = ""
        selectedOption = nil
        gridSlots = [nil, nil, nil, nil]

        pool = viewModel.rounds(for: sport)

        pickQueue = buildUniqueQueue(from: pool, count: pickRoundsPerSession)
        pickIndex = 0

        spellQueue = buildSpellQueue(from: pool, excluding: pickQueue, count: spellRoundsPerSession)
        spellIndex = 0

        phase = .pick

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            startRound()
        }
    }

    private func restartSession() {
        didStart = true
        startSessionAfterScreenShows()
    }

    private func buildUniqueQueue(from rounds: [SightWordRound], count: Int) -> [SightWordRound] {
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
        return uniques
    }

    private func buildSpellQueue(from rounds: [SightWordRound], excluding used: [SightWordRound], count: Int) -> [SightWordRound] {
        let usedWords = Set(used.map { $0.promptWord.lowercased() })
        let preferred = rounds.filter { !usedWords.contains($0.promptWord.lowercased()) }

        let preferredQueue = buildUniqueQueue(from: preferred, count: count)
        if preferredQueue.count == count { return preferredQueue }

        var combined = preferredQueue
        let fallbackQueue = buildUniqueQueue(from: rounds, count: 100)

        for r in fallbackQueue {
            if combined.count == count { break }
            if !combined.contains(where: { $0.promptWord.lowercased() == r.promptWord.lowercased() }) {
                combined.append(r)
            }
        }

        if combined.count > count { return Array(combined.prefix(count)) }
        return combined
    }

    // ✅ Build 4 grid slots: 3 options + 1 blank spot that moves
    private func buildGridSlots(from options: [String]) -> [String?] {
        var slots: [String?] = [nil, nil, nil, nil]
        let blankIndex = Int.random(in: 0..<4)

        var fillIndexes = [0, 1, 2, 3].filter { $0 != blankIndex }.shuffled()
        let shuffled = options.shuffled()

        for (idx, word) in zip(fillIndexes, shuffled) {
            slots[idx] = word
        }
        return slots
    }

    private func startRound() {
        isLocked = true
        isPromptVisible = true
        selectedOption = nil
        feedbackText = ""

        if phase == .spell {
            typedSpelling = ""
        }

        // ✅ Every Pick round gets a new 2x2 layout (blank spot moves)
        if phase == .pick, let round = currentRound {
            gridSlots = buildGridSlots(from: round.options)
        }

        speakCurrentWord()

        DispatchQueue.main.asyncAfter(deadline: .now() + promptVisibleSeconds) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPromptVisible = false
            }
            isLocked = false
        }
    }

    // MARK: - Speech

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

    // MARK: - Pick Actions

    private func choosePick(_ option: String, _ round: SightWordRound) {
        guard !isLocked else { return }
        selectedOption = option
        isLocked = true

        let correct = viewModel.submitAnswer(option, for: round)
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

    // MARK: - Spell Actions

    private func submitSpelling(_ round: SightWordRound) {
        guard !isLocked else { return }
        isLocked = true
        dismissKeyboard()

        let typed = typedSpelling.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correct = round.correctWord.lowercased()
        let isCorrect = (typed == correct)

        _ = viewModel.submitAnswer(isCorrect ? round.correctWord : typedSpelling, for: round)
        savePracticeResult(word: round.promptWord, wasCorrect: isCorrect)

        if isCorrect {
            confettiTrigger += 1
            AudioServicesPlaySystemSound(1104)
            speakCelebration()
            feedbackText = "Nice! You spelled it right."
        } else {
            AudioServicesPlaySystemSound(1053)
            feedbackText = "Close! The correct spelling is “\(round.correctWord)”."
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            advance()
        }
    }

    // MARK: - Advance + Phase Transitions

    private func advance() {
        selectedOption = nil
        feedbackText = ""

        switch phase {
        case .pick:
            pickIndex += 1
            if pickIndex < pickQueue.count {
                startRound()
            } else {
                phase = .spell
                spellIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    startRound()
                }
            }

        case .spell:
            spellIndex += 1
            if spellIndex < spellQueue.count {
                startRound()
            } else {
                endSession()
            }
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

        do { try viewContext.save() }
        catch { print("Failed to save PracticeResult: \(error.localizedDescription)") }
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

        do { try viewContext.save() }
        catch { print("Failed to save SessionSummary: \(error.localizedDescription)") }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
