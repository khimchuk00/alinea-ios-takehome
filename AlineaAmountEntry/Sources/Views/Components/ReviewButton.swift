import SwiftUI

/// The white "Review" pill shown once an amount is entered. Its border is a
/// continuously rotating brand gradient (comment #2), sitting on a soft
/// multicolor glow. The rotation honors Reduce Motion and stops when the button
/// leaves the screen.
///
/// Intentionally non-functional per the brief; `action` defaults to a no-op.
struct ReviewButton: View {
    var action: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double = 0

    var body: some View {
        Button(action: action) {
            ZStack {
                glow
                Capsule()
                    .fill(.white)
                    .shadow(color: .white.opacity(0.12), radius: 5)
                Capsule()
                    .strokeBorder(AppGradient.brandRing(rotation: rotation), lineWidth: Metrics.Size.reviewRing)
                Text("Review")
                    .font(AppFont.review())
                    .tracking(-0.64)
                    .foregroundStyle(AppColor.reviewText)
            }
            .frame(height: Metrics.Size.reviewHeight)
            .contentShape(Capsule())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
        .accessibilityIdentifier(A11y.reviewButton)
        .onAppear(perform: startSpin)
        .onDisappear { rotation = 0 }
    }

    private func startSpin() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: Motion.ringSpinDuration).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }

    /// Blurred multicolor halo behind the pill (an approximation of the Figma
    /// "orb" gradient artwork).
    private var glow: some View {
        Capsule()
            .fill(AppGradient.reviewGlow)
            .frame(height: Metrics.Size.reviewHeight + 10)
            .blur(radius: 20)
            .opacity(0.8)
            .padding(.horizontal, 8)
    }
}
