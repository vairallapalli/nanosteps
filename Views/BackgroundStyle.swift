import SwiftUI

extension View {
    func nanoBackground() -> some View {
        self
            .background(
                LinearGradient(colors: [
                    Color("Ultramarine").opacity(0.03),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom)
            )
    }
}
