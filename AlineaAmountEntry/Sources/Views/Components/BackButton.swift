import SwiftUI

/// The top-left back chevron. Non-functional by design (per the assignment),
/// but rendered for visual parity.
struct BackButton: View {
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                // 36pt visual glyph in a 44pt tap target (HIG minimum).
                .frame(width: Metrics.Size.minTapTarget, height: Metrics.Size.minTapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.9))
        .accessibilityLabel("Back")
    }
}
