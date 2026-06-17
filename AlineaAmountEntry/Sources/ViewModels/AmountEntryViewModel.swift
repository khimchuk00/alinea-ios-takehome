import Foundation
import Observation

/// Drives the amount-entry screen: holds the raw user input and exposes the
/// derived state the views render. All keypad rules from the Figma comments
/// live here so they can be unit-tested in isolation.
@Observable
final class AmountEntryViewModel {

    /// Raw user-entered numeric string: digits with an optional single decimal
    /// point. An empty string means nothing has been entered. Never contains a
    /// currency symbol or grouping separators.
    private(set) var rawInput: String = ""

    // MARK: Configuration

    /// Maximum number of integer digits accepted (keeps very large values sane;
    /// the display itself scales down to fit — comment #7).
    let maxIntegerDigits: Int

    /// Maximum number of fractional digits (cents).
    let maxFractionDigits: Int

    /// Quick-amount suggestions shown while nothing is entered.
    let suggestions: [Int]

    init(initialInput: String = "",
         maxIntegerDigits: Int = 12,
         maxFractionDigits: Int = 2,
         suggestions: [Int] = [500, 2_000, 10_000]) {
        self.rawInput = initialInput
        self.maxIntegerDigits = maxIntegerDigits
        self.maxFractionDigits = maxFractionDigits
        self.suggestions = suggestions
    }

    // MARK: Derived state

    /// True while the entered value is effectively nothing — empty or only
    /// zeros (`""`, `"0"`, `"0."`, `"0.00"`). A lone decimal point is not a
    /// real amount, so it must not unlock Review.
    var isEmpty: Bool {
        !rawInput.contains { $0.isNumber && $0 != "0" }
    }

    /// Comment #1 — suggestion bubbles appear only when nothing is entered.
    var showsSuggestions: Bool { isEmpty }

    /// Comment #6 — the decimal key is "inappropriate" (disabled) once a
    /// decimal point already exists.
    var canAddDecimal: Bool { !rawInput.contains(AmountFormatter.decimalSeparatorChar) }

    /// Formatted amount for display, e.g. `"$1,234.56"`, or the `"$0"`
    /// placeholder while the value is effectively zero.
    var displayAmount: String {
        isEmpty ? AmountFormatter.zeroPlaceholder : AmountFormatter.formatted(rawInput: rawInput)
    }

    // MARK: Intents

    func tapDigit(_ digit: Int) {
        let digitString = String(digit)

        // Replace a lone leading zero so "0" + "5" -> "5", and keep "0" for "0".
        if rawInput.isEmpty || rawInput == "0" {
            rawInput = (digit == 0) ? "0" : digitString
            return
        }

        if let dotIndex = rawInput.firstIndex(of: AmountFormatter.decimalSeparatorChar) {
            let fractionCount = rawInput.distance(from: rawInput.index(after: dotIndex),
                                                  to: rawInput.endIndex)
            guard fractionCount < maxFractionDigits else { return }
        } else {
            guard rawInput.count < maxIntegerDigits else { return }
        }

        rawInput.append(digitString)
    }

    func tapDecimal() {
        guard canAddDecimal else { return }
        let separator = AmountFormatter.decimalSeparator
        rawInput = rawInput.isEmpty ? "0" + separator : rawInput + separator
    }

    func tapBackspace() {
        guard !rawInput.isEmpty else { return }
        rawInput.removeLast()
    }

    func selectSuggestion(_ amount: Int) {
        rawInput = String(amount)
    }

    func reset() {
        rawInput = ""
    }
}
