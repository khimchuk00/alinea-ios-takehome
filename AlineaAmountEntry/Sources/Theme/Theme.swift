import SwiftUI

// MARK: - Colors
//
// Values taken directly from the Figma variables/styles of the
// "Alinea Frontend Take-home" file.

enum AppColor {
    /// Frame fill `bg` — #18161F
    static let background = Color(hex: 0x18161F)

    /// main/white
    static let white = Color.white

    /// main/brand — #B24DCC
    static let brand = Color(hex: 0xB24DCC)
    /// strategies/st01 — #8955F9
    static let brandViolet = Color(hex: 0x8955F9)
    /// strategies/st03 — #2073DF
    static let brandBlue = Color(hex: 0x2073DF)
    /// main/accent — #FFEE59
    static let accent = Color(hex: 0xFFEE59)

    /// Suggestion chip fill — rgba(35,33,44,0.75)
    static let chipBackground = Color(hex: 0x23212C).opacity(0.75)

    /// Review button label — #22212D
    static let reviewText = Color(hex: 0x22212D)

    /// Dimmed "$0" placeholder for the empty state.
    static let amountPlaceholder = Color.white.opacity(0.2)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Fonts
//
// PostScript names verified from the bundled .otf files:
//   GTFlexa-CnMd.otf                     -> "GTFlexa-CnMd"
//   InstrumentSansSemiCondensed-Medium.otf -> "InstrumentSansSemiCondensed-Medium"
// The keypad uses the iOS system font (SF Pro), exactly as in the design.

enum AppFont {
    static let gtFlexaCondensedMedium = "GTFlexa-CnMd"
    static let instrumentSansSemiCondensedMedium = "InstrumentSansSemiCondensed-Medium"

    /// Big amount — GT Flexa Condensed Medium.
    static func amount(_ size: CGFloat) -> Font {
        .custom(gtFlexaCondensedMedium, size: size)
    }

    /// Suggestion chips — Instrument Sans SemiCondensed Medium, 17pt.
    static func chip(_ size: CGFloat = 17) -> Font {
        .custom(instrumentSansSemiCondensedMedium, size: size)
    }

    /// Review label — GT Flexa Condensed Medium.
    static func review(_ size: CGFloat = 21.27) -> Font {
        .custom(gtFlexaCondensedMedium, size: size)
    }

    /// AUTOMATED badge — Instrument Sans SemiCondensed Medium, small.
    static func badge(_ size: CGFloat = 11) -> Font {
        .custom(instrumentSansSemiCondensedMedium, size: size)
    }

    /// Keypad digits — SF Pro Medium (system).
    static func keypad(_ size: CGFloat = 36.65) -> Font {
        .system(size: size, weight: .medium)
    }
}
