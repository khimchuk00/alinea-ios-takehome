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
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.9))
    }
}
