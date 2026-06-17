import Foundation

/// Single source of truth for accessibility identifiers, shared by the views
/// and the UI tests so a rename is a compile error rather than a silently
/// broken test. This file is compiled into both the app and UI-test targets.
enum A11y {
    static let amountDisplay = "amountDisplay"
    static let reviewButton = "reviewButton"
    static let keyDecimal = "key-decimal"
    static let keyDelete = "key-delete"

    static func digitKey(_ digit: Int) -> String { "key-\(digit)" }
    static func chip(_ amount: Int) -> String { "chip-\(amount)" }
}
