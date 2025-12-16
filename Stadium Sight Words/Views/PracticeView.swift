
import SwiftUI

struct PracticeView: View {
    let sport: SportType
    @EnvironmentObject var viewModel: SightWordsViewModel

    @State private var sportRounds: [SightWordRound] = []
    @State private var currentIndex: Int = 0
    @State private var feedbackText: String = ""
    @State private var feedbackIcon: String = ""

    private var currentRound: SightWordRound? {
        guard currentIndex >= 0, currentIndex < sportRounds.count else { return nil }
        return sportRounds[currentIndex]
    }

    var body: some View {
        VStack(spacing: 16) {

            HStack {
                Text("\(sport.displayName) Practice")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("SSText", bundle: nil))
                Spacer()
            }

            HStack(spacing: 14) {
                StatPill(title: "Score", value: "\(viewModel.score)")
                StatPill(title: "Streak", value: "\(viewModel.streak)")
                Spacer()
            }

            if let round = currentRound {
                VStack(spacing: 14) {
                    Text(round.promptWord)
                        .font(.system(size: 56, weight: .black))
                        .foregroundColor(Color("SSText", bundle: nil))
                        .padding(.top, 8)

                    if !feedbackText.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: feedbackIcon)
                            Text(feedbackText)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color("SSText", bundle: nil))
                        .padding(.bottom, 4)
                    }

                    VStack(spacing: 12) {
                        ForEach(round.options, id: \.self) { option in
                            Button {
                                handleTap(option, round: round)
                            } label: {
                                Text(option)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, minHeight: 60)
                            }
                            .buttonStyle(.plain)
                            .background(Color("SSCard", bundle: nil))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                            .foregroundColor(Color("SSText", bundle: nil))
                        }
                    }
                }
            } else {
                Text("No rounds found for \(sport.displayName).")
                    .foregroundColor(Color("SSText", bundle: nil))
                Text("Check that sightwords.json is in Copy Bundle Resources and has items for this sport.")
                    .font(.footnote)
                    .foregroundColor(Color("SSText", bundle: nil))
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
        .background(Color("SSBackground", bundle: nil).ignoresSafeArea())
        .navigationTitle("Practice")
        .onAppear {
            viewModel.resetSession()
            sportRounds = viewModel.rounds(for: sport)
            currentIndex = 0
            feedbackText = ""
            feedbackIcon = ""
        }
    }

    private func handleTap(_ selected: String, round: SightWordRound) {
        let correct = viewModel.submitAnswer(selected, for: round)

        if correct {
            feedbackText = "Goal!"
            feedbackIcon = "checkmark.circle.fill"
        } else {
            feedbackText = "Try again next one!"
            feedbackIcon = "xmark.circle.fill"
        }

        // Move to next round after a short pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            feedbackText = ""
            feedbackIcon = ""
            currentIndex += 1
            if currentIndex >= sportRounds.count {
                currentIndex = 0
            }
        }
    }
}

private struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color("SSText", bundle: nil).opacity(0.8))
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("SSText", bundle: nil))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("SSCard", bundle: nil))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
