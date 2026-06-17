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
                Capsule().strokeBorder(AppGradient.badgeBorder, lineWidth: 1.5)
            )
    }
}
