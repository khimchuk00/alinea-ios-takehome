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

    var body: some View {
        GeometryReader { geo in
            let available = geo.size.width - horizontalPadding * 2
            content(availableWidth: available)
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: maxFontSize * caretHeightRatio)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityIdentifier("amountDisplay")
        .accessibilityLabel(amountText)
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        if isEmpty {
            let size = maxFontSize
            HStack(spacing: 0) {
                Text("$")
                    .foregroundStyle(AppColor.amountPlaceholder)
                BlinkingCaret(height: size * caretHeightRatio, width: caretWidth(size))
                Text("0")
                    .foregroundStyle(AppColor.amountPlaceholder)
            }
            .font(AppFont.amount(size))
            .tracking(-2)
        } else {
            let size = fittingSize(for: amountText, maxWidth: availableWidth)
            HStack(spacing: 0) {
                Text(amountText)
                    .font(AppFont.amount(size))
                    .tracking(size / maxFontSize * -2)
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
                BlinkingCaret(height: size * caretHeightRatio, width: caretWidth(size))
            }
        }
    }

    private func caretWidth(_ size: CGFloat) -> CGFloat {
        max(2.5, size * caretWidthRatio)
    }

    /// Largest GT Flexa size (<= maxFontSize) at which the amount + caret fits
    /// within `maxWidth`.
    private func fittingSize(for text: String, maxWidth: CGFloat) -> CGFloat {
        var size = maxFontSize
        while size > minFontSize {
            if let uiFont = UIFont(name: AppFont.gtFlexaCondensedMedium, size: size) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: uiFont,
                    .kern: size / maxFontSize * -2
                ]
                let width = (text as NSString).size(withAttributes: attributes).width
                if width + caretWidth(size) <= maxWidth { break }
            } else {
                break
            }
            size -= 2
        }
        return size
    }
}
