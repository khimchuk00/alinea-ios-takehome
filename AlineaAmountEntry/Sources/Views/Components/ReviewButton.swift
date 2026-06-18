import SwiftUI

/// The white "Review" pill shown once an amount is entered. Its border is a
/// brand gradient with a bright highlight sweeping around it, sitting on a
/// "breathing" multicolor glow (comment #2). Both honor Reduce Motion and stop
/// when the button leaves the screen.
///
/// Intentionally non-functional per the brief; `action` defaults to a no-op.
struct ReviewButton: View {
    var action: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double = 0
    /// 0 → calm, 1 → fully lit; drives the glow "breathing".
    @State private var glowPulse: CGFloat = 0

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
        .onAppear(perform: startAnimating)
        .onDisappear {
            rotation = 0
            glowPulse = 0
        }
    }

    private func startAnimating() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: Motion.ringSpinDuration).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        withAnimation(.easeInOut(duration: Motion.glowPulseDuration).repeatForever(autoreverses: true)) {
            glowPulse = 1
        }
    }

    /// Blurred multicolor halo behind the pill (an approximation of the Figma
    /// "orb" gradient artwork), gently breathing in brightness and spread.
    private var glow: some View {
        Capsule()
            .fill(AppGradient.reviewGlow)
            .frame(height: Metrics.Size.reviewHeight + 10)
            .blur(radius: 20)
            .opacity(0.78 + 0.15 * glowPulse)
            .scaleEffect(x: 1, y: 1 + 0.04 * glowPulse, anchor: .center)
            .padding(.horizontal, 8)
    }
}
