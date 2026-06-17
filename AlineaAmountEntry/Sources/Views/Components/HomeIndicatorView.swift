import SwiftUI

/// The bottom home indicator pill.
struct HomeIndicatorView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 100, style: .continuous)
            .fill(.white)
            .frame(width: 135, height: 5)
            .opacity(0.4)
            .frame(height: 24, alignment: .center)
    }
}
