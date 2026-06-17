import SwiftUI

/// The row of quick-amount suggestion chips. Shown only while nothing is
/// entered (comment #1).
struct QuickAmountChipsView: View {
    let amounts: [Int]
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(amounts, id: \.self) { amount in
                Button {
                    onSelect(amount)
                } label: {
                    Text(label(for: amount))
                        .font(AppFont.chip())
                        .tracking(-0.17)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppColor.chipBackground, in: Capsule())
                }
                .buttonStyle(PressableStyle(scale: 0.96))
                .accessibilityIdentifier("chip-\(amount)")
            }
        }
    }

    private func label(for amount: Int) -> String {
        AmountFormatter.formatted(rawInput: String(amount))
    }
}

/// Generic pressed-state styling reused by tappable controls.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.94
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
