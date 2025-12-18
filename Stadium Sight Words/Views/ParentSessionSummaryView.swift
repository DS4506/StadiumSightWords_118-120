
import SwiftUI

struct ParentSessionSummaryView: View {
    let sport: SportType
    let score: Int
    let totalAnswered: Int
    let correctCount: Int
    let incorrectCount: Int
    let accuracyPercent: Int
    let bestStreak: Int

    let onStartNewSession: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.20, blue: 0.55),
                    Color(red: 0.15, green: 0.70, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Session Summary")
                    .font(.title.weight(.heavy))
                    .foregroundColor(.white)

                Text("\(sport.displayName) Practice")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.95))

                VStack(spacing: 12) {
                    summaryRow("Total Answered", "\(totalAnswered)")
                    summaryRow("Correct", "\(correctCount)")
                    summaryRow("Incorrect", "\(incorrectCount)")
                    summaryRow("Accuracy", "\(accuracyPercent)%")
                    summaryRow("Best Streak", "\(bestStreak)")
                    summaryRow("Score", "\(score)")
                }
                .padding()
                .background(.white.opacity(0.92))
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)

                Text(parentMessage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(.black.opacity(0.35))
                            .cornerRadius(14)
                    }

                    Button {
                        onStartNewSession()
                    } label: {
                        Text("Start New Session")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color.green.opacity(0.55))
                            .cornerRadius(14)
                    }
                }
                .padding(.top, 6)
            }
            .padding()
            .frame(maxWidth: 560)
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black.opacity(0.78))
            Spacer()
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundColor(.black.opacity(0.86))
        }
    }

    private var parentMessage: String {
        if totalAnswered == 0 { return "Start a few rounds and we will track progress here." }
        if accuracyPercent >= 90 { return "Excellent work. Strong accuracy and focus today." }
        if accuracyPercent >= 75 { return "Great progress. Keep practicing for even faster recognition." }
        return "Good effort. A few short sessions this week will boost confidence fast."
    }
}
