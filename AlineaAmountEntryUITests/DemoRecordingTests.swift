import XCTest

/// A scripted walkthrough of the screen used to record the demo video.
/// It also serves as a broad end-to-end smoke test of the full flow.
final class DemoRecordingTests: XCTestCase {
    func testFullKeypadDemo() {
        let app = XCUIApplication()
        app.launch()

        func pause(_ seconds: Double = 0.45) { Thread.sleep(forTimeInterval: seconds) }

        pause(1.0)

        // Type $2,500 — chips animate out, Review animates in.
        for key in ["key-2", "key-5", "key-0", "key-0"] {
            app.buttons[key].tap()
            pause()
        }
        pause(0.8)

        // Backspace back to empty — suggestion chips return.
        for _ in 0..<4 {
            app.buttons["key-delete"].tap()
            pause(0.4)
        }
        pause(0.7)

        // Pick a suggestion chip.
        app.buttons["chip-10000"].tap()
        pause(1.0)

        // Clear, then enter a decimal amount (decimal key disables afterwards).
        for _ in 0..<5 {
            app.buttons["key-delete"].tap()
            pause(0.22)
        }
        pause(0.5)
        for key in ["key-4", "key-2", "key-decimal", "key-5", "key-0"] {
            app.buttons[key].tap()
            pause(0.4)
        }
        pause(0.9)

        // Clear, then type a large value to show the amount auto-scaling.
        for _ in 0..<6 {
            app.buttons["key-delete"].tap()
            pause(0.18)
        }
        pause(0.4)
        for key in ["key-9", "key-8", "key-7", "key-6", "key-5", "key-4", "key-3", "key-2"] {
            app.buttons[key].tap()
            pause(0.32)
        }
        pause(1.4)
    }
}
