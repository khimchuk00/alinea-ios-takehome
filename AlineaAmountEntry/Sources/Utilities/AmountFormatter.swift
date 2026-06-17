import Foundation

/// Pure formatting helpers for the amount entry.
///
/// The grouping (`,`) and decimal (`.`) separators are fixed to match the
/// design (US currency style) regardless of the device locale, so screenshots
/// stay identical across regions.
enum AmountFormatter {
    static let currencySymbol = "$"
    static let groupingSeparator = ","
    static let decimalSeparator = "."

    /// Formats a raw numeric input string (digits with an optional single ".")
    /// into a currency string such as `"$1,234.56"`. An empty input yields the
    /// `"$0"` placeholder.
    static func formatted(rawInput: String) -> String {
        guard !rawInput.isEmpty else { return currencySymbol + "0" }

        let hasDecimal = rawInput.contains(decimalSeparator)
        let components = rawInput.components(separatedBy: decimalSeparator)
        let integerPart = components.first ?? ""
        let grouped = grouped(integerDigits: integerPart)

        guard hasDecimal else { return currencySymbol + grouped }

        let fraction = components.count > 1 ? components[1] : ""
        return currencySymbol + grouped + decimalSeparator + fraction
    }

    /// Inserts thousands separators into a run of integer digits, normalising
    /// leading zeros (e.g. `"007"` -> `"7"`, `""` -> `"0"`).
    static func grouped(integerDigits: String) -> String {
        let stripped = String(integerDigits.drop(while: { $0 == "0" }))
        let normalized = stripped.isEmpty ? "0" : stripped

        var output = ""
        for (offset, character) in normalized.reversed().enumerated() {
            if offset > 0, offset % 3 == 0 {
                output.append(contentsOf: groupingSeparator)
            }
            output.append(character)
        }
        return String(output.reversed())
    }
}
