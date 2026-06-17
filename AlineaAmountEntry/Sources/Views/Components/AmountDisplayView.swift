import SwiftUI
import UIKit

/// The large amount display with a trailing blinking caret.
///
/// - Empty state: a dimmed "$0" placeholder with the caret between "$" and "0".
/// - Entered state: the white formatted amount with the caret at the end.
/// - The font shrinks so large values still fit on screen (comment #7).
struct AmountDisplayView: View {
    let isEmpty: Bool
    let amountText: String

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
        .accessibilityLabel(amountText)
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        if isEmpty {
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
                    .foregroundStyle(
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0.0),
                                .init(color: .white, location: 0.46),
                                .init(color: Color.white.opacity(0.58), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.45), radius: 1, x: 0, y: 4)
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
        guard let uiFont = UIFont(name: AppFont.gtFlexaCondensedMedium, size: maxFontSize) else {
            return maxFontSize
        }
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
