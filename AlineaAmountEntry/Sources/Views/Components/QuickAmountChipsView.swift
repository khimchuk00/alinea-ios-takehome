import SwiftUI

/// The row of quick-amount suggestion chips. Shown only while nothing is entered.
struct QuickAmountChipsView: View {
    let amounts: [Int]
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: Metrics.Size.chipSpacing) {
            ForEach(amounts, id: \.self) { amount in
                Button {
                    onSelect(amount)
                } label: {
                    Text(AmountFormatter.formatted(rawInput: String(amount)))
                        .font(AppFont.chip())
                        .tracking(-0.17)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.Size.chipHeight)
                        .background(AppColor.chipBackground, in: Capsule())
                        .overlay(Capsule().strokeBorder(AppGradient.chipBorder, lineWidth: 1))
                }
                .buttonStyle(PressableStyle(scale: 0.96))
                .accessibilityIdentifier(A11y.chip(amount))
            }
        }
    }
}
