
import SwiftUI

struct SportBackgroundView: View {
    let sport: SportType

    var body: some View {
        switch sport {
        case .basketball:
            BasketballCourtBackground()
        case .soccer:
            SoccerFieldBackground()
        case .football:
            FootballFieldBackground()
        }
    }
}

// MARK: - Basketball Court

private struct BasketballCourtBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.55, blue: 0.20),
                    Color(red: 0.75, green: 0.35, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                Path { p in
                    // Outer border
                    p.addRoundedRect(in: CGRect(x: 20, y: 20, width: w - 40, height: h - 40), cornerSize: CGSize(width: 24, height: 24))

                    // Half court line
                    p.move(to: CGPoint(x: w / 2, y: 40))
                    p.addLine(to: CGPoint(x: w / 2, y: h - 40))

                    // Center circle
                    p.addEllipse(in: CGRect(x: w/2 - 90, y: h/2 - 90, width: 180, height: 180))

                    // Key areas (simple)
                    p.addRoundedRect(in: CGRect(x: 30, y: h/2 - 120, width: 140, height: 240), cornerSize: CGSize(width: 18, height: 18))
                    p.addRoundedRect(in: CGRect(x: w - 170, y: h/2 - 120, width: 140, height: 240), cornerSize: CGSize(width: 18, height: 18))
                }
                .stroke(Color.white.opacity(0.7), lineWidth: 4)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 6)
            }
        }
    }
}

// MARK: - Soccer Field

private struct SoccerFieldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.70, blue: 0.35),
                    Color(red: 0.06, green: 0.45, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Stripes
            VStack(spacing: 0) {
                ForEach(0..<10) { i in
                    Rectangle()
                        .fill(Color.white.opacity(i.isMultiple(of: 2) ? 0.08 : 0.03))
                }
            }
            .opacity(0.9)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                Path { p in
                    p.addRoundedRect(in: CGRect(x: 18, y: 18, width: w - 36, height: h - 36), cornerSize: CGSize(width: 26, height: 26))

                    // Midfield line
                    p.move(to: CGPoint(x: 18, y: h / 2))
                    p.addLine(to: CGPoint(x: w - 18, y: h / 2))

                    // Center circle
                    p.addEllipse(in: CGRect(x: w/2 - 95, y: h/2 - 95, width: 190, height: 190))

                    // Boxes
                    p.addRect(CGRect(x: w/2 - 170, y: 18, width: 340, height: 160))
                    p.addRect(CGRect(x: w/2 - 170, y: h - 178, width: 340, height: 160))
                }
                .stroke(Color.white.opacity(0.75), lineWidth: 4)
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 5)
            }
        }
    }
}

// MARK: - Football Field

private struct FootballFieldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.55, blue: 0.25),
                    Color(red: 0.04, green: 0.32, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Yard stripes
            VStack(spacing: 0) {
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(Color.white.opacity(i.isMultiple(of: 2) ? 0.06 : 0.02))
                }
            }
            .opacity(0.95)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                Path { p in
                    p.addRoundedRect(in: CGRect(x: 18, y: 18, width: w - 36, height: h - 36), cornerSize: CGSize(width: 26, height: 26))

                    // Yard lines (simple)
                    let lines = 8
                    for i in 1..<lines {
                        let y = 18 + (CGFloat(i) * (h - 36) / CGFloat(lines))
                        p.move(to: CGPoint(x: 18, y: y))
                        p.addLine(to: CGPoint(x: w - 18, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.65), lineWidth: 3)
                .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 5)
            }
        }
    }
}
