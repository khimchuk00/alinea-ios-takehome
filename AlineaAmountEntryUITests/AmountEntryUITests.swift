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

    private func currentAmount() -> String {
        let element = app.staticTexts[A11y.amountDisplay].exists
            ? app.staticTexts[A11y.amountDisplay]
            : app.otherElements[A11y.amountDisplay]
        return (element.value as? String) ?? element.label
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
