import SwiftUI
import UIKit

/// The large amount display with a trailing blinking caret.
///
/// - Empty state: a dimmed "$0" placeholder with the caret between "$" and "0".
/// - Entered state: the white formatted amount with the caret at the end.
/// - The font shrinks so large values still fit on screen.
struct AmountDisplayView: View {
    /// Dim "$0" placeholder with the caret between "$" and "0" (nothing typed
    /// yet). Anything typed — including a lone decimal — renders as a bright,
    /// "active" amount.
    let isPlaceholder: Bool
    let amountText: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let maxFontSize: CGFloat = 100
    private let minFontSize: CGFloat = 30
    private let horizontalPadding: CGFloat = 24
    private let caretHeightRatio: CGFloat = 1.06
    private let caretWidthRatio: CGFloat = 0.03

    /// Typographic tracking factor for GT Flexa at `maxFontSize`, scaled with the
    /// font size. Defined once so the rendered text and the width measurement can
    /// never drift apart.
    private let trackingFactor: CGFloat = -2

    var body: some View {
        GeometryReader { geo in
            let available = geo.size.width - horizontalPadding * 2
            content(availableWidth: available)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: maxFontSize * caretHeightRatio)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityIdentifier(A11y.amountDisplay)
        .accessibilityLabel("Amount")
        .accessibilityValue(amountText)
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        if isPlaceholder {
            HStack(spacing: 0) {
                Text("$").foregroundStyle(AppColor.amountPlaceholder)
                caret(for: maxFontSize)
                Text("0").foregroundStyle(AppColor.amountPlaceholder)
            }
            .font(AppFont.amount(maxFontSize))
            .tracking(kern(for: maxFontSize))
        } else {
            let size = fittingSize(for: amountText, maxWidth: availableWidth)
            HStack(spacing: 0) {
                Text(amountText)
                    .font(AppFont.amount(size))
                    .tracking(kern(for: size))
                    .lineLimit(1)
                    .minimumScaleFactor(minFontSize / maxFontSize)
                    .foregroundStyle(AppGradient.amountText)
                    .shadow(color: .black.opacity(0.45), radius: 1, x: 0, y: 4)
                    // Roll the digits as the value changes while typing (honors
                    // Reduce Motion, like the rest of the screen's animation).
                    .contentTransition(.numericText())
                    .animation(reduceMotion ? nil : Motion.amountChange, value: amountText)
                caret(for: size)
            }
        }
    }

    private func caret(for size: CGFloat) -> some View {
        BlinkingCaret(height: size * caretHeightRatio, width: caretWidth(size))
    }

    private func caretWidth(_ size: CGFloat) -> CGFloat {
        max(2.5, size * caretWidthRatio)
    }

    private func kern(for size: CGFloat) -> CGFloat {
        size / maxFontSize * trackingFactor
    }

    /// The largest GT Flexa size (within `[minFontSize, maxFontSize]`) at which
    /// the amount plus caret fits in `maxWidth`. Measures once at the max size and
    /// scales down exactly, so it never skips sizes or returns an unmeasured floor.
    private func fittingSize(for text: String, maxWidth: CGFloat) -> CGFloat {
        // Fall back to a system font for measurement if the custom font is
        // missing, so the text still shrinks instead of pinning to the max size.
        let uiFont = UIFont(name: AppFont.gtFlexaCondensedMedium, size: maxFontSize)
            ?? .systemFont(ofSize: maxFontSize, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: uiFont,
            .kern: kern(for: maxFontSize)
        ]
        let measured = (text as NSString).size(withAttributes: attributes).width + caretWidth(maxFontSize)
        guard measured > maxWidth else { return maxFontSize }
        let scaled = maxFontSize * (maxWidth / measured)
        return min(maxFontSize, max(minFontSize, scaled))
    }
}
