import SwiftUI

/// A static iOS-style status bar (time + signal/Wi-Fi/battery) reproducing the
/// "9:41" mock that is part of the design.
///
/// The design frame includes its own status bar and home indicator, so the
/// screen is rendered full-bleed (`.ignoresSafeArea()`) and this view recreates
/// that chrome for 1:1 parity. The trade-off is that the layout is tuned to the
/// design's iPhone geometry rather than reading live safe-area insets; a
/// production screen would instead let the system status bar show through and
/// drive spacing from `safeAreaInsets`.
struct StatusBarView: View {
    var body: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 16, weight: .semibold))
                .tracking(-0.3)
                .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 7) {
                SignalBars()
                Image(systemName: "wifi")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                BatteryIcon()
            }
        }
        .padding(.horizontal, Metrics.Inset.statusBar)
        .frame(height: Metrics.Size.statusBarHeight)
        .accessibilityHidden(true)  // decorative mock chrome
    }
}

private struct SignalBars: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(.white)
                    .frame(width: 3, height: 4 + CGFloat(index) * 2.7)
            }
        }
    }
}

private struct BatteryIcon: View {
    var body: some View {
        HStack(spacing: 1.5) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                    .stroke(.white.opacity(0.4), lineWidth: 1)
                    .frame(width: 24, height: 12)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(.white)
                    .frame(width: 20, height: 8)
                    .padding(.leading, 2)
            }
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(.white.opacity(0.4))
                .frame(width: 1.5, height: 4)
        }
    }
}
