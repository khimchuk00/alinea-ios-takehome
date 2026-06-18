import UIKit

/// Light haptic feedback for keypad interactions.
@MainActor
enum Haptics {
    private static let generator = UIImpactFeedbackGenerator(style: .light)

    /// Warm up the Taptic Engine to minimise feedback latency.
    static func prepare() {
        generator.prepare()
    }

    /// Fire a light impact for a keypad tap, then re-prepare for the next one.
    static func keyTap() {
        generator.impactOccurred()
        generator.prepare()
    }
}
