import Foundation
import Observation

/// Drives the amount-entry screen: holds the raw user input and exposes the
/// derived state the views render. All the keypad rules live here so they can
/// be unit-tested in isolation.
@Observable
final class AmountEntryViewModel {

    /// Raw user-entered numeric string: digits with an optional single decimal
    /// point. An empty string means nothing has been entered. Never contains a
    /// currency symbol or grouping separators.
    private(set) var rawInput: String = ""

    // MARK: Configuration

    /// Maximum number of integer digits accepted (keeps very large values sane;
    /// the display itself scales down to fit).
    let maxIntegerDigits: Int

    /// Maximum number of fractional digits (cents).
    let maxFractionDigits: Int

    /// Quick-amount suggestions shown while nothing is entered.
    let suggestions: [Int]

    init(initialInput: String = "",
         maxIntegerDigits: Int = 12,
         maxFractionDigits: Int = 2,
         suggestions: [Int] = [500, 2_000, 10_000]) {
        self.maxIntegerDigits = maxIntegerDigits
        self.maxFractionDigits = maxFractionDigits
        self.suggestions = suggestions
        self.rawInput = Self.sanitized(initialInput,
                                       maxIntegerDigits: maxIntegerDigits,
                                       maxFractionDigits: maxFractionDigits)
    }

    // MARK: Derived state

    /// True while the entered value is effectively nothing — empty or only
    /// zeros (`""`, `"0"`, `"0."`, `"0.00"`). A lone decimal point is not a
    /// real amount, so it must not unlock Review.
    var isEmpty: Bool {
        !rawInput.contains { $0.isNumber && $0 != "0" }
    }

    /// Suggestion bubbles appear only when nothing is entered.
    var showsSuggestions: Bool { isEmpty }

    /// The decimal key is disabled once a decimal point already exists.
    var canAddDecimal: Bool { !rawInput.contains(AmountFormatter.decimalSeparatorChar) }

    /// True only before the user has typed anything meaningful (empty or a lone
    /// "0"): the display shows the dim "$0" placeholder with the caret between
    /// "$" and "0". A typed decimal ("0.") is NOT a placeholder — it's shown.
    var isPlaceholder: Bool { rawInput.isEmpty || rawInput == "0" }

    /// Formatted amount for display, e.g. `"$1,234.56"` or `"$0."`. Faithful to
    /// the entered text so a typed decimal point is always visible.
    var displayAmount: String {
        AmountFormatter.formatted(rawInput: rawInput)
    }

    // MARK: Intents

    func tapDigit(_ digit: Int) {
        let digitString = String(digit)

        // Replace a lone leading zero so "0" + "5" -> "5", and keep "0" for "0".
        if isPlaceholder {
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
        // Route through the same clamp/normalisation as every other entry path.
        rawInput = Self.sanitized(String(max(0, amount)),
                                  maxIntegerDigits: maxIntegerDigits,
                                  maxFractionDigits: maxFractionDigits)
    }

    /// Coerces an externally-provided string into the `rawInput` invariant
    /// (digits, at most one decimal point, within the length limits) so the
    /// DEBUG prefill / any external seed can't produce malformed state.
    private static func sanitized(_ input: String,
                                  maxIntegerDigits: Int,
                                  maxFractionDigits: Int) -> String {
        var integerDigits = ""
        var fractionDigits = ""
        var sawDot = false
        for character in input {
            if character.isNumber {
                if sawDot { fractionDigits.append(character) } else { integerDigits.append(character) }
            } else if character == AmountFormatter.decimalSeparatorChar, !sawDot {
                sawDot = true
            }
        }
        // Strip leading zeros BEFORE clamping so they don't consume the integer
        // budget (mirrors the keypad, which replaces a lone "0"); then cap the
        // significant digits and reinstate a leading "0" where the form needs one.
        var integer = String(integerDigits.drop(while: { $0 == "0" }))
        if integer.count > maxIntegerDigits {
            integer = String(integer.prefix(maxIntegerDigits))
        }
        if integer.isEmpty, sawDot || !integerDigits.isEmpty {
            integer = "0"
        }
        let fraction = String(fractionDigits.prefix(maxFractionDigits))
        return sawDot ? integer + AmountFormatter.decimalSeparator + fraction : integer
    }
}
