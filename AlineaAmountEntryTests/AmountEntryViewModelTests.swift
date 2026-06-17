import XCTest
@testable import AlineaAmountEntry

final class AmountEntryViewModelTests: XCTestCase {

    private func makeViewModel() -> AmountEntryViewModel { AmountEntryViewModel() }

    // MARK: Initial state

    func testInitialStateIsEmpty() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.showsSuggestions)
        XCTAssertTrue(viewModel.canAddDecimal)
        XCTAssertEqual(viewModel.displayAmount, "$0")
    }

    // MARK: Digits & grouping

    func testTypingDigitsGroupsThousands() {
        let viewModel = makeViewModel()
        [2, 0, 0, 0].forEach(viewModel.tapDigit)
        XCTAssertEqual(viewModel.rawInput, "2000")
        XCTAssertEqual(viewModel.displayAmount, "$2,000")
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertFalse(viewModel.showsSuggestions)
    }

    func testLargeNumberGrouping() {
        let viewModel = makeViewModel()
        [1, 2, 3, 4, 5, 6, 7].forEach(viewModel.tapDigit)
        XCTAssertEqual(viewModel.displayAmount, "$1,234,567")
    }

    // MARK: Leading zero handling

    func testLeadingZeroIsReplaced() {
        let viewModel = makeViewModel()
        viewModel.tapDigit(0)
        XCTAssertEqual(viewModel.rawInput, "0")
        XCTAssertTrue(viewModel.isEmpty)            // "$0" counts as the empty state
        XCTAssertEqual(viewModel.displayAmount, "$0")

        viewModel.tapDigit(5)
        XCTAssertEqual(viewModel.rawInput, "5")
        XCTAssertEqual(viewModel.displayAmount, "$5")
    }

    func testMultipleZerosStayZero() {
        let viewModel = makeViewModel()
        [0, 0, 0].forEach(viewModel.tapDigit)
        XCTAssertEqual(viewModel.rawInput, "0")
        XCTAssertTrue(viewModel.isEmpty)
    }

    // MARK: Decimal behaviour (comment #6)

    func testDecimalOnEmptyAddsLeadingZeroButStaysEmpty() {
        let viewModel = makeViewModel()
        viewModel.tapDecimal()
        XCTAssertEqual(viewModel.rawInput, "0.")
        XCTAssertFalse(viewModel.canAddDecimal)
        // "0." is effectively zero: suggestions stay, Review stays hidden.
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.showsSuggestions)
        XCTAssertEqual(viewModel.displayAmount, "$0")
    }

    func testZeroThenDecimalIsStillEmpty() {
        let viewModel = makeViewModel()
        viewModel.tapDigit(0)
        viewModel.tapDecimal()
        XCTAssertEqual(viewModel.rawInput, "0.")
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.showsSuggestions)
    }

    func testZerosWithDecimalBecomeNonEmptyOnNonZeroDigit() {
        let viewModel = makeViewModel()
        viewModel.tapDecimal()   // "0."
        viewModel.tapDigit(0)    // "0.0" — still zero
        XCTAssertTrue(viewModel.isEmpty)
        viewModel.tapDigit(5)    // "0.05" — now a real amount
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.displayAmount, "$0.05")
    }

    func testSecondDecimalIsIgnored() {
        let viewModel = makeViewModel()
        [1, 2].forEach(viewModel.tapDigit)
        viewModel.tapDecimal()
        viewModel.tapDecimal()  // must be ignored
        XCTAssertEqual(viewModel.rawInput, "12.")
        XCTAssertFalse(viewModel.canAddDecimal)
    }

    func testFractionLimitedToTwoDigits() {
        let viewModel = makeViewModel()
        viewModel.tapDigit(5)
        viewModel.tapDecimal()
        [9, 9, 9].forEach(viewModel.tapDigit)   // only two accepted
        XCTAssertEqual(viewModel.rawInput, "5.99")
        XCTAssertEqual(viewModel.displayAmount, "$5.99")
    }

    func testDecimalThenDigit() {
        let viewModel = makeViewModel()
        [2, 0, 0, 0].forEach(viewModel.tapDigit)
        viewModel.tapDecimal()
        viewModel.tapDigit(5)
        XCTAssertEqual(viewModel.displayAmount, "$2,000.5")
    }

    // MARK: Backspace

    func testBackspaceRemovesLastDigit() {
        let viewModel = makeViewModel()
        [1, 2, 3].forEach(viewModel.tapDigit)
        viewModel.tapBackspace()
        XCTAssertEqual(viewModel.rawInput, "12")
        XCTAssertEqual(viewModel.displayAmount, "$12")
    }

    func testBackspaceToEmptyRestoresSuggestions() {
        let viewModel = makeViewModel()
        viewModel.tapDigit(7)
        viewModel.tapBackspace()
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.showsSuggestions)
        XCTAssertEqual(viewModel.displayAmount, "$0")
    }

    func testBackspaceOnEmptyIsNoop() {
        let viewModel = makeViewModel()
        viewModel.tapBackspace()
        XCTAssertEqual(viewModel.rawInput, "")
    }

    func testBackspaceRemovesDecimalPoint() {
        let viewModel = makeViewModel()
        viewModel.tapDigit(5)
        viewModel.tapDecimal()
        XCTAssertFalse(viewModel.canAddDecimal)
        viewModel.tapBackspace()           // removes the "."
        XCTAssertEqual(viewModel.rawInput, "5")
        XCTAssertTrue(viewModel.canAddDecimal)
    }

    // MARK: Suggestions (comment #1)

    func testSelectSuggestionShowsReview() {
        let viewModel = makeViewModel()
        viewModel.selectSuggestion(2_000)
        XCTAssertEqual(viewModel.rawInput, "2000")
        XCTAssertEqual(viewModel.displayAmount, "$2,000")
        XCTAssertFalse(viewModel.showsSuggestions)
    }

    func testSuggestionsToggleWithEntry() {
        let viewModel = makeViewModel()
        viewModel.tapDigit(5)
        XCTAssertFalse(viewModel.showsSuggestions)
        viewModel.tapBackspace()
        XCTAssertTrue(viewModel.showsSuggestions)
    }

    // MARK: Limits

    func testMaxIntegerDigitsEnforced() {
        let viewModel = AmountEntryViewModel(maxIntegerDigits: 4)
        [1, 2, 3, 4, 5, 6].forEach(viewModel.tapDigit)
        XCTAssertEqual(viewModel.rawInput, "1234")
    }

    func testDefaultMaxIntegerDigitsCapsAtTwelve() {
        let viewModel = makeViewModel()
        for _ in 0..<15 { viewModel.tapDigit(9) }
        XCTAssertEqual(viewModel.rawInput, "999999999999")
        XCTAssertEqual(viewModel.displayAmount, "$999,999,999,999")
    }

    func testFractionCapWithGroupedInteger() {
        let viewModel = makeViewModel()
        [1, 2, 3, 4].forEach(viewModel.tapDigit)
        viewModel.tapDecimal()
        [5, 6, 7].forEach(viewModel.tapDigit)  // only two fraction digits accepted
        XCTAssertEqual(viewModel.displayAmount, "$1,234.56")
    }

    // MARK: External input is sanitized to the rawInput invariant

    func testInitialInputDropsInvalidCharactersAndExtraDot() {
        let viewModel = AmountEntryViewModel(initialInput: "ab1,2x3.4.5!")
        XCTAssertEqual(viewModel.rawInput, "123.45")
        XCTAssertEqual(viewModel.displayAmount, "$123.45")
    }

    func testInitialInputClampsToLimits() {
        let viewModel = AmountEntryViewModel(initialInput: "1234567890123456")
        XCTAssertEqual(viewModel.rawInput, "123456789012")
    }

    func testInitialInputNormalizesLeadingZeros() {
        XCTAssertEqual(AmountEntryViewModel(initialInput: "007").rawInput, "7")
        XCTAssertEqual(AmountEntryViewModel(initialInput: "000").rawInput, "0")
    }

    func testReset() {
        let viewModel = makeViewModel()
        [1, 2, 3].forEach(viewModel.tapDigit)
        viewModel.reset()
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertEqual(viewModel.rawInput, "")
    }

    // MARK: Formatter

    func testFormatterDirectly() {
        XCTAssertEqual(AmountFormatter.formatted(rawInput: ""), "$0")
        XCTAssertEqual(AmountFormatter.formatted(rawInput: "1000000"), "$1,000,000")
        XCTAssertEqual(AmountFormatter.formatted(rawInput: "1234.5"), "$1,234.5")
        XCTAssertEqual(AmountFormatter.formatted(rawInput: "0."), "$0.")
        XCTAssertEqual(AmountFormatter.grouped(integerDigits: "007"), "7")
    }
}
