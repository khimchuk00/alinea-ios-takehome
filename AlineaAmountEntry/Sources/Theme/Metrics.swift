import SwiftUI

// MARK: - Metrics
//
// Dimensional design tokens taken from the Figma frame (393×853 iPhone).
// Keeping them here makes the 1:1 spec traceable and tunable in one place
// instead of scattered literals across the views.
// (Named `Metrics` rather than `Layout` to avoid colliding with SwiftUI's
// `Layout` protocol.)

enum Metrics {
    /// The Figma artboard size the screen was designed against.
    static let designSize = CGSize(width: 393, height: 853)

    /// Horizontal insets, per section (they intentionally differ in the design).
    enum Inset {
        static let statusBar: CGFloat = 32
        static let nav: CGFloat = 18
        static let chips: CGFloat = 41
        static let review: CGFloat = 24
        static let keypad: CGFloat = 6
    }

    /// Vertical rhythm of the screen.
    enum Spacing {
        static let navTop: CGFloat = 27
        static let navToAmount: CGFloat = 142
        static let swapToKeypad: CGFloat = 30
        static let keypadToHome: CGFloat = 6
        static let homeToBottom: CGFloat = 6
    }

    /// Fixed element sizes.
    enum Size {
        /// Minimum tappable size (Apple HIG).
        static let minTapTarget: CGFloat = 44
        static let statusBarHeight: CGFloat = 47
        static let navRowHeight: CGFloat = 36
        static let backButton: CGFloat = 36
        static let swapHeight: CGFloat = 50
        static let chipHeight: CGFloat = 44
        static let chipSpacing: CGFloat = 12
        static let keyHeight: CGFloat = 68
        static let reviewHeight: CGFloat = 50
        static let reviewRing: CGFloat = 2.5
        static let homeIndicator = CGSize(width: 135, height: 5)
        static let topGlowDiameter: CGFloat = 519
        static let topGlowOffsetY: CGFloat = -273
    }
}

// MARK: - Motion
//
// Shared animations and motion constants (comments #2 and #3).

enum Motion {
    /// Chips ↔ Review swap (comment #3).
    static let swap = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static let chipsTransitionScale: CGFloat = 0.85
    static let reviewTransitionScale: CGFloat = 0.92

    /// Review border gradient rotation (comment #2).
    static let ringSpinDuration: Double = 2.2
    /// Review glow "breathing" pulse.
    static let glowPulseDuration: Double = 1.4

    /// Caret blink (comment #5).
    static let caretBlinkDuration: Double = 0.55

    /// Generic press feedback and key enable/disable.
    static let press = Animation.easeOut(duration: 0.12)
    static let keyEnable = Animation.easeOut(duration: 0.18)

    /// Top glow fade-in.
    static let glowFade = Animation.easeInOut(duration: 0.5)
}
