import SwiftUI

/// A blinking text caret (comment #5). Its opacity is derived from wall-clock
/// time via `TimelineView`, so the blink phase is stable even when the view is
/// recreated (font-size changes, empty↔entered swap) instead of jumping back to
/// full opacity. Honors Reduce Motion.
struct BlinkingCaret: View {
    var height: CGFloat
    var width: CGFloat = 3

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            RoundedRectangle(cornerRadius: width / 2, style: .continuous)
                .fill(Color.white)
                .frame(width: width, height: height)
                .opacity(opacity(at: context.date))
        }
        .accessibilityHidden(true)
    }

    private func opacity(at date: Date) -> Double {
        guard !reduceMotion else { return 1 }
        let period = Motion.caretBlinkDuration * 2  // full on→off→on cycle
        let phase = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
        return (cos(phase * 2 * .pi) + 1) / 2
    }
}
