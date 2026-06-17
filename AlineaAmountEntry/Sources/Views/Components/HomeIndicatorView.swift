import SwiftUI

/// The bottom home indicator pill.
struct HomeIndicatorView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 100, style: .continuous)
            .fill(.white)
            .frame(width: Metrics.Size.homeIndicator.width, height: Metrics.Size.homeIndicator.height)
            .opacity(0.4)
            .frame(height: 24, alignment: .center)
            .accessibilityHidden(true)  // decorative mock chrome
    }
}
