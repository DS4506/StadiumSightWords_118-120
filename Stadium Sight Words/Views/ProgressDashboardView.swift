
import SwiftUI
import CoreData

struct ProgressDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PracticeResult.timestamp, ascending: false)],
        animation: .default
    )
    private var results: FetchedResults<PracticeResult>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SessionSummary.timestamp, ascending: false)],
        animation: .default
    )
    private var sessions: FetchedResults<SessionSummary>

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.52, blue: 0.96),
                        Color(red: 0.50, green: 0.35, blue: 0.95),
                        Color(red: 0.96, green: 0.55, blue: 0.68)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        Text("Progress Dashboard")
                            .font(.title2.weight(.heavy))
                            .foregroundColor(.white)
                            .padding(.top, 10)

                        card(title: "Sessions Completed", value: "\(sessions.count)")

                        sportSection(.soccer)
                        sportSection(.basketball)
                        sportSection(.football)

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func sportSection(_ sport: SportType) -> some View {
        let sportKey = sport.rawValue
        let sportResults = results.filter { $0.sport == sportKey }

        let total = sportResults.count
        let correct = sportResults.filter { $0.wasCorrect }.count
        let accuracy = total == 0 ? 0 : Int((Double(correct) / Double(total)) * 100.0)

        let missed = topMissedWords(for: sportKey, limit: 5)

        return VStack(spacing: 10) {
            HStack {
                Text("\(sport.displayName)")
                    .font(.headline.weight(.heavy))
                    .foregroundColor(.white)
                Spacer()
                Text("Accuracy: \(accuracy)%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 12) {
                card(title: "Attempts", value: "\(total)")
                card(title: "Correct", value: "\(correct)")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Top Missed Words")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white.opacity(0.95))

                if missed.isEmpty {
                    Text("No missed words yet.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                } else {
                    ForEach(missed, id: \.0) { pair in
                        Text("\(pair.0)  •  \(pair.1)x")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding()
            .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding()
        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func topMissedWords(for sportKey: String, limit: Int) -> [(String, Int)] {
        let missed = results.filter { $0.sport == sportKey && $0.wasCorrect == false }
        var counts: [String: Int] = [:]
        for r in missed {
            let w = r.word ?? ""
            if !w.isEmpty { counts[w, default: 0] += 1 }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }

    private func card(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.85))
            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
