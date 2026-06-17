import SwiftUI

/// A blinking text caret (comment #5). Its size is driven by the amount font so
/// it scales together with the displayed value.
struct BlinkingCaret: View {
    var height: CGFloat
    var width: CGFloat = 3

    @State private var visible = true

    var body: some View {
        RoundedRectangle(cornerRadius: width / 2, style: .continuous)
            .fill(Color.white)
            .frame(width: width, height: height)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
            .accessibilityHidden(true)
    }
}
