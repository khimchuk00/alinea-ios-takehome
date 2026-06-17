import SwiftUI

/// A blinking text caret (comment #5). Its opacity is derived from wall-clock
/// time via `TimelineView`, so the blink phase is stable even when the view is
/// recreated (font-size changes, empty↔entered swap) instead of jumping back to
/// full opacity. Under Reduce Motion it renders as a steady bar with no ticking
/// timeline.
struct BlinkingCaret: View {
    var height: CGFloat
    var width: CGFloat = 3

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                bar
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    bar.opacity(opacity(at: context.date))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private var bar: some View {
        RoundedRectangle(cornerRadius: width / 2, style: .continuous)
            .fill(Color.white)
            .frame(width: width, height: height)
    }

    private func opacity(at date: Date) -> Double {
        let period = Motion.caretBlinkDuration * 2  // full on→off→on cycle
        let phase = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
        return (cos(phase * 2 * .pi) + 1) / 2
    }
}
