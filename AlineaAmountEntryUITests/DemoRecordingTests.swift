import XCTest

/// A scripted walkthrough of the screen used to record the demo video.
///
/// Excluded from the default test action (see `skippedTests` in project.yml)
/// because it is paced with `Thread.sleep` for the recording rather than being a
/// fast assertion-based test. Run it explicitly to record:
///   xcodebuild test -only-testing:AlineaAmountEntryUITests/DemoRecordingTests
@MainActor
final class DemoRecordingTests: XCTestCase {
    func testFullKeypadDemo() {
        let app = XCUIApplication()
        app.launch()

        func tap(_ id: String) { app.buttons[id].tap() }
        func pause(_ seconds: Double = 0.45) { Thread.sleep(forTimeInterval: seconds) }

        pause(1.0)

        // Type $2,500 — chips animate out, Review animates in.
        for digit in [2, 5, 0, 0] { tap(A11y.digitKey(digit)); pause() }
        pause(0.8)

        // Backspace back to empty — suggestion chips return.
        for _ in 0..<4 { tap(A11y.keyDelete); pause(0.4) }
        pause(0.7)

        // Pick a suggestion chip.
        tap(A11y.chip(10_000))
        pause(1.0)

        // Clear, then enter a decimal amount (decimal key disables afterwards).
        for _ in 0..<5 { tap(A11y.keyDelete); pause(0.22) }
        pause(0.5)
        for digit in [4, 2] { tap(A11y.digitKey(digit)); pause(0.4) }
        tap(A11y.keyDecimal); pause(0.4)
        for digit in [5, 0] { tap(A11y.digitKey(digit)); pause(0.4) }
        pause(0.9)

        // Clear, then type a large value to show the amount auto-scaling.
        for _ in 0..<6 { tap(A11y.keyDelete); pause(0.18) }
        pause(0.4)
        for digit in [9, 8, 7, 6, 5, 4, 3, 2] { tap(A11y.digitKey(digit)); pause(0.32) }
        pause(1.4)
    }
}
