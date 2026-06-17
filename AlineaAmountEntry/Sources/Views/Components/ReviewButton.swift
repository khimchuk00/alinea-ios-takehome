import SwiftUI

/// The white "Review" pill shown once an amount is entered. Its border is a
/// continuously rotating brand gradient (comment #2), sitting on a soft
/// multicolor glow.
struct ReviewButton: View {
    var action: () -> Void = {}

    private let height: CGFloat = 50
    private let ringWidth: CGFloat = 2.5

    @State private var rotation: Double = 0

    private var ringColors: [Color] {
        [AppColor.brand, AppColor.brandViolet, AppColor.brandBlue, AppColor.brandViolet, AppColor.brand]
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                glow
                Capsule()
                    .fill(.white)
                    .shadow(color: .white.opacity(0.12), radius: 5)
                Capsule()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: ringColors),
                            center: .center,
                            startAngle: .degrees(rotation),
                            endAngle: .degrees(rotation + 360)
                        ),
                        lineWidth: ringWidth
                    )
                Text("Review")
                    .font(AppFont.review())
                    .tracking(-0.64)
                    .foregroundStyle(AppColor.reviewText)
            }
            .frame(height: height)
            .contentShape(Capsule())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
        .accessibilityIdentifier("reviewButton")
        .onAppear {
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    /// Blurred multicolor halo behind the pill (an approximation of the Figma
    /// "orb" gradient artwork).
    private var glow: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        AppColor.brandBlue,
                        AppColor.brandViolet,
                        AppColor.brand,
                        AppColor.accent.opacity(0.7)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height + 10)
            .blur(radius: 20)
            .opacity(0.8)
            .padding(.horizontal, 8)
    }
}
