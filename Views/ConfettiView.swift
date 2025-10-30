import SwiftUI


struct ConfettiView: View {
    @Binding var isActive: Bool
    let duration: Double = 1.2
    @State private var items: [ConfettiItem] = []

    var body: some View {
        ZStack {
            ForEach(items) { item in
                Circle()
                    .fill(item.color)
                    .frame(width: item.size, height: item.size)
                    .position(item.position)
                    .opacity(item.opacity)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { active in
            guard active else { return }
            spawn()
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                items.removeAll()
                isActive = false
            }
        }
    }



    private func spawn() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        items = (0..<18).map { _ in
            let x = CGFloat.random(in: 0...width)
            let startY = CGFloat.random(in: -40...(-10))
            let endY = CGFloat.random(in: (height/3)...(height*0.9))
            return ConfettiItem(
                position: CGPoint(x: x, y: startY),
                target: CGPoint(x: x + CGFloat.random(in: -40...40), y: endY),
                size: CGFloat.random(in: 6...12),
                color: [Color.blue, .indigo, .cyan, .mint, .purple].randomElement()!,
                opacity: Double.random(in: 0.7...1.0)
            )
        }
        withAnimation(.interpolatingSpring(stiffness: 40, damping: 8)) {
            for i in items.indices {
                items[i].position = items[i].target
                items[i].opacity = 0.0
            }
        }
    }
}

struct ConfettiItem: Identifiable {
    let id = UUID()
    var position: CGPoint
    var target: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}
