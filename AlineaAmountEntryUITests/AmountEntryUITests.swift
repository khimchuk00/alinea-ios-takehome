import XCTest

/// End-to-end checks that the number pad is fully functional and drives the
/// displayed amount.
@MainActor
final class AmountEntryUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
    }

    @discardableResult
    private func launch(prefill: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        if let prefill { app.launchEnvironment["AMOUNT_PREFILL"] = prefill }
        app.launch()
        self.app = app
        return app
    }

    private func amountElement() -> XCUIElement {
        app.staticTexts[A11y.amountDisplay].exists
            ? app.staticTexts[A11y.amountDisplay]
            : app.otherElements[A11y.amountDisplay]
    }

    private func currentAmount() -> String {
        let element = amountElement()
        return (element.value as? String) ?? element.label
    }

    /// Polls until the amount settles on `expected` — used for the async
    /// hold-to-repeat delete, whose timing depends on the run loop.
    @discardableResult
    private func waitForAmount(_ expected: String, timeout: TimeInterval = 3) -> Bool {
        let predicate = NSPredicate(format: "value == %@", expected)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: amountElement())
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    func testStartsInEmptyState() {
        launch()
        XCTAssertEqual(currentAmount(), "$0")
        XCTAssertTrue(app.buttons[A11y.chip(500)].exists)
        XCTAssertFalse(app.buttons[A11y.reviewButton].exists)
    }

    func testKeypadEntersAndGroupsAmount() {
        launch()
        [2, 0, 0, 0].forEach { app.buttons[A11y.digitKey($0)].tap() }
        XCTAssertEqual(currentAmount(), "$2,000")
        XCTAssertTrue(app.buttons[A11y.reviewButton].waitForExistence(timeout: 2))
    }

    func testBackspaceRemovesDigits() {
        launch()
        [1, 2, 3].forEach { app.buttons[A11y.digitKey($0)].tap() }
        app.buttons[A11y.keyDelete].tap()
        XCTAssertEqual(currentAmount(), "$12")
    }

    func testDecimalIsDisabledAfterUse() {
        launch()
        app.buttons[A11y.digitKey(5)].tap()
        XCTAssertTrue(app.buttons[A11y.keyDecimal].isEnabled)
        app.buttons[A11y.keyDecimal].tap()
        app.buttons[A11y.digitKey(2)].tap()
        app.buttons[A11y.digitKey(5)].tap()
        XCTAssertEqual(currentAmount(), "$5.25")
        XCTAssertFalse(app.buttons[A11y.keyDecimal].isEnabled)
    }

    /// Once two decimal places are entered no further digit will register, so the
    /// digit keys grey out (are disabled) too.
    func testDigitKeysGreyOutWhenFractionIsFull() {
        launch()
        [5].forEach { app.buttons[A11y.digitKey($0)].tap() }
        app.buttons[A11y.keyDecimal].tap()
        [2, 5].forEach { app.buttons[A11y.digitKey($0)].tap() }
        XCTAssertEqual(currentAmount(), "$5.25")
        XCTAssertFalse(app.buttons[A11y.digitKey(7)].isEnabled)
        XCTAssertFalse(app.buttons[A11y.digitKey(0)].isEnabled)
        XCTAssertFalse(app.buttons[A11y.keyDecimal].isEnabled)
        XCTAssertTrue(app.buttons[A11y.keyDelete].isEnabled)
    }

    /// Press-and-hold on delete should clear several digits, not just one.
    func testHoldingDeleteClearsMultipleDigits() {
        launch(prefill: "12345")
        XCTAssertEqual(currentAmount(), "$12,345")
        app.buttons[A11y.keyDelete].press(forDuration: 1.3)
        XCTAssertTrue(waitForAmount("$0"), "Holding delete should clear the field")
    }

    func testSuggestionChipFillsAmountAndShowsReview() {
        launch()
        app.buttons[A11y.chip(2000)].tap()
        XCTAssertEqual(currentAmount(), "$2,000")
        XCTAssertTrue(app.buttons[A11y.reviewButton].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons[A11y.chip(500)].exists)
    }

    /// The largest legal value still renders as a single grouped label
    /// (exercises the auto-shrink path).
    func testLargeValueStaysGrouped() {
        launch()
        for _ in 0..<12 { app.buttons[A11y.digitKey(9)].tap() }
        XCTAssertEqual(currentAmount(), "$999,999,999,999")
    }

    /// The DEBUG-only AMOUNT_PREFILL hook seeds the entered state on cold launch.
    func testLaunchPrefillSeedsEnteredState() {
        launch(prefill: "2000")
        XCTAssertEqual(currentAmount(), "$2,000")
        XCTAssertTrue(app.buttons[A11y.reviewButton].waitForExistence(timeout: 2))
    }
}
