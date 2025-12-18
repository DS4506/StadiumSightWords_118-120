
import SwiftUI

struct ConfettiBurstView: View {
    let trigger: Int

    @State private var pieces: [ConfettiPiece] = []
    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiShape(type: piece.shape)
                        .fill(piece.color)
                        .frame(width: piece.size.width, height: piece.size.height)
                        .rotationEffect(.degrees(animate ? piece.endRotation : piece.startRotation))
                        .position(
                            x: (animate ? piece.endX : piece.startX) * geo.size.width,
                            y: animate ? geo.size.height + 60 : -60
                        )
                        .opacity(animate ? 0.0 : 1.0)
                        .animation(.easeOut(duration: piece.duration).delay(piece.delay), value: animate)
                }
            }
            .onChangeCompat(of: trigger) {
                launchConfetti()
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func launchConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .blue, .purple, .pink]
        let shapes: [ConfettiShapeType] = [.circle, .rectangle, .star]

        pieces = (0..<80).map { _ in
            ConfettiPiece(
                startX: Double.random(in: 0.25...0.75),
                endX: Double.random(in: 0.05...0.95),
                startRotation: Double.random(in: 0...180),
                endRotation: Double.random(in: 360...1080),
                color: colors.randomElement() ?? .white,
                shape: shapes.randomElement() ?? .rectangle,
                size: CGSize(width: Double.random(in: 8...14), height: Double.random(in: 8...14)),
                duration: Double.random(in: 1.0...1.7),
                delay: Double.random(in: 0.0...0.18)
            )
        }

        animate = false
        DispatchQueue.main.async {
            animate = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            pieces.removeAll()
        }
    }
}

// MARK: - iOS 15+ / iOS 17+ onChange compatibility (no deprecation warnings)
private extension View {
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value, initial: false) { _, _ in
                action()
            }
        } else {
            self.onChange(of: value) { _ in
                action()
            }
        }
    }
}

// MARK: - Confetti Types

private enum ConfettiShapeType {
    case circle
    case rectangle
    case star
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let startX: Double
    let endX: Double
    let startRotation: Double
    let endRotation: Double
    let color: Color
    let shape: ConfettiShapeType
    let size: CGSize
    let duration: Double
    let delay: Double
}

// MARK: - Shape wrapper (fixes "some Shape" switch return issue)
private struct ConfettiShape: Shape {
    let type: ConfettiShapeType

    func path(in rect: CGRect) -> Path {
        switch type {
        case .circle:
            return Circle().path(in: rect)
        case .rectangle:
            return RoundedRectangle(cornerRadius: 2).path(in: rect)
        case .star:
            return StarShape(points: 5, innerRatio: 0.45).path(in: rect)
        }
    }
}

// Simple star shape
private struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        guard points >= 5 else { return Path() }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * innerRatio

        var path = Path()
        var angle = -CGFloat.pi / 2
        let step = CGFloat.pi / CGFloat(points)

        var firstPoint = true
        for i in 0..<(points * 2) {
            let r = (i % 2 == 0) ? outerR : innerR
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            let p = CGPoint(x: x, y: y)

            if firstPoint {
                path.move(to: p)
                firstPoint = false
            } else {
                path.addLine(to: p)
            }

            angle += step
        }

        path.closeSubpath()
        return path
    }
}
