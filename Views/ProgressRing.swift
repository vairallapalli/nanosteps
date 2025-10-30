import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var size: CGFloat = 56
    var lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle().stroke(.gray.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(AngularGradient(gradient: Gradient(colors: [.blue, .indigo]),
                                        center: .center),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.caption2).bold()
        }
        .frame(width: size, height: size)
    }
}
