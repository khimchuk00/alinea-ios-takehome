import XCTest

/// End-to-end checks that the number pad is fully functional and drives the
/// displayed amount (the core requirement of the assignment).
final class AmountEntryUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func currentAmount() -> String {
        if app.staticTexts["amountDisplay"].exists {
            return app.staticTexts["amountDisplay"].label
        }
        return app.otherElements["amountDisplay"].label
    }

    func testStartsInEmptyState() {
        XCTAssertEqual(currentAmount(), "$0")
        XCTAssertTrue(app.buttons["chip-500"].exists)
        XCTAssertFalse(app.buttons["reviewButton"].exists)
    }

    func testKeypadEntersAndGroupsAmount() {
        app.buttons["key-2"].tap()
        app.buttons["key-0"].tap()
        app.buttons["key-0"].tap()
        app.buttons["key-0"].tap()
        XCTAssertEqual(currentAmount(), "$2,000")
        XCTAssertTrue(app.buttons["reviewButton"].waitForExistence(timeout: 2))
    }

    func testBackspaceRemovesDigits() {
        app.buttons["key-1"].tap()
        app.buttons["key-2"].tap()
        app.buttons["key-3"].tap()
        app.buttons["key-delete"].tap()
        XCTAssertEqual(currentAmount(), "$12")
    }

    func testDecimalIsDisabledAfterUse() {
        app.buttons["key-5"].tap()
        XCTAssertTrue(app.buttons["key-decimal"].isEnabled)
        app.buttons["key-decimal"].tap()
        app.buttons["key-2"].tap()
        app.buttons["key-5"].tap()
        XCTAssertEqual(currentAmount(), "$5.25")
        XCTAssertFalse(app.buttons["key-decimal"].isEnabled)
    }

    func testSuggestionChipFillsAmountAndShowsReview() {
        app.buttons["chip-2000"].tap()
        XCTAssertEqual(currentAmount(), "$2,000")
        XCTAssertTrue(app.buttons["reviewButton"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["chip-500"].exists)
    }
}
