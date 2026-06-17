import SwiftUI

/// The soft radial glow near the top of the screen (present in the entered
/// state of the design). Fades in once an amount is entered.
struct TopGlow: View {
    var isVisible: Bool

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color.white.opacity(0.10), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 260
                )
            )
            .frame(width: 519, height: 519)
            .offset(y: -273)
            .blur(radius: 24)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: isVisible)
            .allowsHitTesting(false)
    }
}
