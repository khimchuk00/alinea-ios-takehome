import SwiftUI

enum KeypadKey: Hashable {
    case digit(Int)
    case decimal
    case backspace
}

/// The numeric keypad. Every key fires light haptics; the decimal key disables
/// itself once a decimal point already exists.
struct KeypadView: View {
    let canAddDecimal: Bool
    let onDigit: (Int) -> Void
    let onDecimal: () -> Void
    let onBackspace: () -> Void

    private let rows: [[KeypadKey]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.decimal, .digit(0), .backspace]
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(rows[row], id: \.self) { key in
                        keyView(key)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func keyView(_ key: KeypadKey) -> some View {
        switch key {
        case .digit(let value):
            KeypadButton(action: { onDigit(value) }) {
                Text("\(value)")
                    .font(AppFont.keypad())
                    .tracking(-1.1)
                    .foregroundStyle(.white)
            }
            .accessibilityIdentifier(A11y.digitKey(value))
        case .decimal:
            KeypadButton(isEnabled: canAddDecimal, action: onDecimal) {
                Text(AmountFormatter.decimalSeparator)
                    .font(AppFont.keypad())
                    .foregroundStyle(.white)
            }
            .accessibilityIdentifier(A11y.keyDecimal)
            .accessibilityLabel("Decimal point")
        case .backspace:
            KeypadButton(action: onBackspace) {
                Image("icon.backspace")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 42, height: 38)
            }
            .accessibilityIdentifier(A11y.keyDelete)
            .accessibilityLabel("Delete")
        }
    }
}

/// A single keypad key: full-width tap target, press feedback and haptics.
struct KeypadButton<Label: View>: View {
    var isEnabled: Bool = true
    let action: () -> Void
    @ViewBuilder var label: () -> Label

    private let disabledOpacity: CGFloat = 0.3

    var body: some View {
        Button {
            Haptics.keyTap()
            action()
        } label: {
            label()
                .frame(maxWidth: .infinity)
                .frame(height: Metrics.Size.keyHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.88))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : disabledOpacity)
        .animation(Motion.keyEnable, value: isEnabled)
    }
}
