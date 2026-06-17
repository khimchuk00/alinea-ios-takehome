import SwiftUI

/// The "AUTOMATED" pill in the navigation bar, with a brand-gradient border.
struct AutomatedBadge: View {
    var body: some View {
        Text("AUTOMATED")
            .font(AppFont.badge(10))
            .tracking(0.8)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AppColor.background.opacity(0.35), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                AppColor.brandBlue,
                                AppColor.brandViolet,
                                AppColor.brand,
                                AppColor.brandBlue
                            ]),
                            center: .center
                        ),
                        lineWidth: 1.5
                    )
            )
    }
}
