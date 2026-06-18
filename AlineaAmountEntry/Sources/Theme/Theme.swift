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

    /// Canonical brand color ramp — the single source for every brand gradient.
    static let brandRamp: [Color] = [brand, brandViolet, brandBlue]

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

// MARK: - Gradients
//
// Every brand gradient derives from `AppColor.brandRamp`, so the palette is
// tuned in exactly one place.

enum AppGradient {
    /// A bright tint for the highlight that sweeps the Review border.
    static let ringHighlight = Color(hex: 0xF2D9FF)

    /// Seamless loop (first and last stop match) carrying a bright "shine" band
    /// that travels around the Review border as it rotates (comment #2).
    static var brandRingStops: [Gradient.Stop] {
        [
            .init(color: AppColor.brandBlue, location: 0.00),
            .init(color: AppColor.brandViolet, location: 0.16),
            .init(color: AppColor.brand, location: 0.30),
            // A wider, lingering highlight so the sheen glides instead of
            // snapping across the rounded corners.
            .init(color: ringHighlight, location: 0.44),
            .init(color: ringHighlight, location: 0.50),
            .init(color: AppColor.brand, location: 0.64),
            .init(color: AppColor.brandViolet, location: 0.80),
            .init(color: AppColor.brandBlue, location: 1.00)
        ]
    }

    /// Rotating angular gradient for the Review button border.
    static func brandRing(rotation: Double) -> AngularGradient {
        AngularGradient(
            gradient: Gradient(stops: brandRingStops),
            center: .center,
            startAngle: .degrees(rotation),
            endAngle: .degrees(rotation + 360)
        )
    }

    /// Static brand border for the AUTOMATED badge.
    static var badgeBorder: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: AppColor.brandRamp.reversed() + [AppColor.brandBlue]),
            center: .center
        )
    }

    /// Soft multicolor halo behind the Review pill.
    static var reviewGlow: LinearGradient {
        LinearGradient(
            colors: AppColor.brandRamp.reversed() + [AppColor.accent.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Top-lit hairline border on the suggestion chips (glassy raised look).
    static let chipBorder = LinearGradient(
        stops: [
            .init(color: Color.white.opacity(0.30), location: 0.0),
            .init(color: Color.white.opacity(0.07), location: 0.5),
            .init(color: Color.white.opacity(0.0), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Top-to-bottom shine on the large amount (subtle 3D depth).
    static let amountText = LinearGradient(
        stops: [
            .init(color: .white, location: 0.0),
            .init(color: .white, location: 0.46),
            .init(color: Color.white.opacity(0.58), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
