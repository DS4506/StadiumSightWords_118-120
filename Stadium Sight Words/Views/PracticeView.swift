
//  PracticeView.swift
//  Stadium Sight Words

import SwiftUI
import AVFoundation
import AudioToolbox

struct PracticeView: View {
    let sport: SportType

    @EnvironmentObject private var vm: SightWordsViewModel
    @Environment(\.dismiss) private var dismiss

    // Rounds for this sport
    @State private var sportRounds: [SightWordRound] = []
    @State private var currentIndex: Int = 0

    // Memory mode (prompt visible briefly, then hidden)
    @State private var isPromptVisible: Bool = true
    private let promptVisibleSeconds: Double = 1.5

    // Confetti
    @State private var confettiTrigger: Int = 0

    // End-of-session summary
    @State private var showSummary: Bool = false

    // Speech (no @StateObject needed)
    private let speech = SpeechManager()

    // Prevent double taps while transitioning
    @State private var isAcceptingInput: Bool = true

    private var currentRound: SightWordRound? {
        guard currentIndex >= 0, currentIndex < sportRounds.count else { return nil }
        return sportRounds[currentIndex]
    }

    var body: some View {
        ZStack {
            SportBackgroundView(sport: sport)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header
                statsRow

                Spacer(minLength: 12)

                promptArea
                optionsArea

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 18)

            ConfettiBurstView(trigger: confettiTrigger)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupSession()
        }
        .sheet(isPresented: $showSummary) {
            SessionSummarySheet(
                sportName: sport.displayName,
                score: vm.score,
                totalAnswered: vm.totalAnswered,
                correctCount: vm.correctCount,
                incorrectCount: vm.incorrectCount,
                accuracyPercent: vm.accuracyPercent,
                bestStreak: vm.bestStreak,
                onDone: { dismiss() },
                onStartNewSession: {
                    vm.resetSession()
                    currentIndex = 0
                    showSummary = false
                    startRound()
                }
            )
        }
    }

    // MARK: - UI Pieces

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(sport.displayName) Practice")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(.white)

                Text("Listen, remember, then choose the right word.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Button {
                speakCurrentPrompt()
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel("Hear the sight word")
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatPill(title: "Score", value: "\(vm.score)")
            StatPill(title: "Streak", value: "\(vm.streak)")
            StatPill(title: "Round", value: "\(min(currentIndex + 1, max(sportRounds.count, 1)))")
        }
    }

    private var promptArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.20), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Text(isPromptVisible ? (currentRound?.promptWord ?? "") : " ")
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 14)

                Text(isPromptVisible ? "Look fast..." : "Now pick from memory!")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }

    private var optionsArea: some View {
        VStack(spacing: 12) {
            ForEach(currentRound?.options ?? [], id: \.self) { option in
                Button {
                    handleSelection(option)
                } label: {
                    HStack {
                        Text(option)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.black.opacity(0.85))
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.92))
                    )
                }
                .disabled(!isAcceptingInput || currentRound == nil)
            }
        }
    }

    // MARK: - Session Flow

    private func setupSession() {
        sportRounds = vm.rounds(for: sport)
        vm.resetSession()
        currentIndex = 0
        showSummary = false
        startRound()
    }

    private func startRound() {
        guard currentRound != nil else {
            showSummary = true
            return
        }

        isAcceptingInput = true
        isPromptVisible = true

        // Speak immediately
        speakCurrentPrompt()

        // Hide after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + promptVisibleSeconds) {
            withAnimation(.easeInOut(duration: 0.25)) {
                isPromptVisible = false
            }
        }
    }

    private func speakCurrentPrompt() {
        guard let word = currentRound?.promptWord, !word.isEmpty else { return }
        speech.speak(word)
    }

    private func handleSelection(_ selected: String) {
        guard isAcceptingInput, let round = currentRound else { return }
        isAcceptingInput = false

        let isCorrect = vm.submitAnswer(selected, for: round)

        if isCorrect {
            confettiTrigger += 1
            AudioServicesPlaySystemSound(1057)
        } else {
            AudioServicesPlaySystemSound(1053)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            currentIndex += 1
            startRound()
        }
    }
}

// MARK: - Small Components

private struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Speech Manager (no ObservableObject needed)

final class SpeechManager {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synth.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.1
        utterance.postUtteranceDelay = 0.05
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())

        synth.speak(utterance)
    }
}

// MARK: - Summary Sheet

private struct SessionSummarySheet: View {
    let sportName: String
    let score: Int
    let totalAnswered: Int
    let correctCount: Int
    let incorrectCount: Int
    let accuracyPercent: Int
    let bestStreak: Int

    let onDone: () -> Void
    let onStartNewSession: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Session Summary")
                    .font(.title2.weight(.heavy))

                Text("\(sportName) Practice")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    row("Score", "\(score)")
                    row("Answered", "\(totalAnswered)")
                    row("Correct", "\(correctCount)")
                    row("Incorrect", "\(incorrectCount)")
                    row("Accuracy", "\(accuracyPercent)%")
                    row("Best Streak", "\(bestStreak)")
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                HStack(spacing: 12) {
                    Button("Done") { onDone() }
                        .buttonStyle(.bordered)

                    Button("Start New Session") { onStartNewSession() }
                        .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Parents")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.headline.weight(.bold))
        }
    }
}
