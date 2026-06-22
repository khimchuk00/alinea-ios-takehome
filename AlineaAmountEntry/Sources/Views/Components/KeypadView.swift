import SwiftUI

enum KeypadKey: Hashable {
    case digit(Int)
    case decimal
    case backspace
}

/// The numeric keypad. Every key fires light haptics. The decimal key disables
/// itself once a decimal point exists, the digit keys grey out when no further
/// digit will register, and the delete key repeats while held down.
struct KeypadView: View {
    let canAddDecimal: Bool
    let canAddDigit: Bool
    let canDelete: Bool
    let onDigit: (Int) -> Void
    let onDecimal: () -> Void
    /// Returns whether a character was actually removed, so the delete key's
    /// hold-to-repeat loop stops on its own once there's nothing left.
    let onBackspace: () -> Bool

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
            KeypadButton(isEnabled: canAddDigit, action: { onDigit(value) }) {
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
            HoldRepeatKey(isEnabled: canDelete, action: onBackspace) {
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
        .buttonStyle(PressableStyle(scale: KeypadMetrics.pressScale))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : KeypadMetrics.disabledOpacity)
        .animation(Motion.keyEnable, value: isEnabled)
    }
}

/// A keypad key that repeats its action while held down — used for delete, so a
/// long press clears several digits. A quick tap fires once. Mirrors
/// `KeypadButton`'s size, press feedback and haptics.
///
/// `action` returns whether it changed anything; the repeat loop reads that live
/// result each tick (rather than a captured copy of `isEnabled`) and stops on its
/// own once there's nothing left to delete. It also stops if the key is disabled,
/// leaves the screen, or the app is interrupted (a call, Control Center, etc.).
struct HoldRepeatKey<Label: View>: View {
    var isEnabled: Bool = true
    let action: () -> Bool
    @ViewBuilder var label: () -> Label

    @Environment(\.scenePhase) private var scenePhase
    @State private var isPressed = false
    @State private var repeatTask: Task<Void, Never>?

    var body: some View {
        label()
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.Size.keyHeight)
            .contentShape(Rectangle())
            .pressFeedback(isPressed: isPressed, scale: KeypadMetrics.pressScale)
            .opacity(isEnabled ? 1 : KeypadMetrics.disabledOpacity)
            .animation(Motion.keyEnable, value: isEnabled)
            .gesture(pressGesture)
            .disabled(!isEnabled)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { _ = fire() }
            .accessibilityAction(named: Text("Clear all"), clearAll)
            .onChange(of: isEnabled) { _, enabled in if !enabled { stop() } }
            .onChange(of: scenePhase) { _, phase in if phase != .active { stop() } }
            .onDisappear(perform: stop)
    }

    private var pressGesture: some Gesture {
        // minimumDistance 0 → fires on touch-down; a quick tap is down+up.
        DragGesture(minimumDistance: 0)
            .onChanged { _ in if !isPressed { start() } }
            .onEnded { _ in stop() }
    }

    private func start() {
        isPressed = true
        guard fire() else { return }  // first delete on touch-down
        repeatTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(Motion.deleteRepeatDelay))
            var interval = Motion.deleteRepeatInterval
            while !Task.isCancelled {
                guard fire() else { break }  // nothing left — stop the loop
                try? await Task.sleep(for: .seconds(interval))
                interval = max(Motion.deleteRepeatMinInterval, interval * Motion.deleteRepeatDecay)
            }
        }
    }

    /// Performs one delete, returning whether anything changed.
    @discardableResult
    private func fire() -> Bool {
        let didChange = action()
        if didChange { Haptics.keyTap() }
        return didChange
    }

    /// Clears the whole field — exposed to VoiceOver/Switch Control as a custom
    /// action, since they can't perform the press-and-hold gesture.
    private func clearAll() {
        var didChange = false
        while action() { didChange = true }
        if didChange { Haptics.keyTap() }
    }

    private func stop() {
        isPressed = false
        repeatTask?.cancel()
        repeatTask = nil
    }
}

private enum KeypadMetrics {
    static let pressScale: CGFloat = 0.88
    static let disabledOpacity: CGFloat = 0.3
}
