import SwiftUI

/// App-wide pressed-state styling reused by every tappable control
/// (chips, keypad keys, Review, back).
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.94

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .pressFeedback(isPressed: configuration.isPressed, scale: scale)
    }
}

extension View {
    /// The shared pressed-state appearance — a slight shrink and dim. Used both
    /// by `PressableStyle` and by the hold-to-repeat delete key, which can't be a
    /// `ButtonStyle`, so the press feel stays identical across every key.
    func pressFeedback(isPressed: Bool, scale: CGFloat) -> some View {
        scaleEffect(isPressed ? scale : 1)
            .opacity(isPressed ? PressFeedback.pressedOpacity : 1)
            .animation(Motion.press, value: isPressed)
    }
}

private enum PressFeedback {
    static let pressedOpacity: CGFloat = 0.8
}
