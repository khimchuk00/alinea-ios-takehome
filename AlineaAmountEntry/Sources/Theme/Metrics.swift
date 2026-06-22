import SwiftUI

// MARK: - Metrics
//
// Dimensional design tokens for the screen (393×853 reference, iPhone).
// Keeping them here makes the layout traceable and tunable in one place
// instead of scattered literals across the views.
// (Named `Metrics` rather than `Layout` to avoid colliding with SwiftUI's
// `Layout` protocol.)

enum Metrics {
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
// Shared animations and motion constants.

enum Motion {
    /// Chips ↔ Review swap.
    static let swap = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static let chipsTransitionScale: CGFloat = 0.85
    static let reviewTransitionScale: CGFloat = 0.92

    /// Review border gradient rotation.
    static let ringSpinDuration: Double = 4.5
    /// Review glow "breathing" pulse.
    static let glowPulseDuration: Double = 2.6

    /// Caret blink.
    static let caretBlinkDuration: Double = 0.55

    /// Amount value change — drives the rolling digit (`numericText`) animation
    /// as the user types.
    static let amountChange = Animation.spring(response: 0.32, dampingFraction: 0.72)

    /// Generic press feedback and key enable/disable.
    static let press = Animation.easeOut(duration: 0.12)
    static let keyEnable = Animation.easeOut(duration: 0.18)

    /// Press-and-hold delete: how long to wait before auto-repeat kicks in, the
    /// starting repeat interval, and the floor it accelerates toward (so a long
    /// hold clears faster the longer it's held).
    static let deleteRepeatDelay: Double = 0.4
    static let deleteRepeatInterval: Double = 0.11
    static let deleteRepeatMinInterval: Double = 0.045
    static let deleteRepeatDecay: Double = 0.86

    /// Top glow fade-in.
    static let glowFade = Animation.easeInOut(duration: 0.5)
}
