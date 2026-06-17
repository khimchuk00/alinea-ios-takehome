import SwiftUI

/// The amount-entry screen — assembles all components and binds them to the
/// view model. Laid out edge-to-edge to mirror the 393×853 Figma frame.
struct AmountEntryView: View {
    @State private var viewModel: AmountEntryViewModel

    init() {
        // Optional seed used for previews/screenshots: launch with
        // `AMOUNT_PREFILL=2000` to start in the entered state. No effect otherwise.
        let prefill = ProcessInfo.processInfo.environment["AMOUNT_PREFILL"] ?? ""
        _viewModel = State(initialValue: AmountEntryViewModel(initialInput: prefill))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                AppColor.background
                TopGlow(isVisible: !viewModel.isEmpty)
                content
                    .frame(width: geo.size.width)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .onAppear { Haptics.prepare() }
    }

    private var content: some View {
        VStack(spacing: 0) {
            StatusBarView()

            navigationRow
                .padding(.top, 27)
                .padding(.horizontal, 18)

            Spacer().frame(height: 142)

            AmountDisplayView(isEmpty: viewModel.isEmpty, amountText: viewModel.displayAmount)

            Spacer(minLength: 0)

            swapSlot
                .frame(height: 50)

            Spacer().frame(height: 30)

            KeypadView(
                canAddDecimal: viewModel.canAddDecimal,
                onDigit: { viewModel.tapDigit($0) },
                onDecimal: { viewModel.tapDecimal() },
                onBackspace: { viewModel.tapBackspace() }
            )
            .padding(.horizontal, 6)

            Spacer().frame(height: 6)

            HomeIndicatorView()

            Spacer().frame(height: 6)
        }
    }

    private var navigationRow: some View {
        ZStack {
            HStack {
                BackButton()
                Spacer()
            }
            AutomatedBadge()
        }
        .frame(height: 36)
    }

    @ViewBuilder
    private var swapSlot: some View {
        ZStack {
            if viewModel.showsSuggestions {
                QuickAmountChipsView(
                    amounts: viewModel.suggestions,
                    onSelect: { viewModel.selectSuggestion($0) }
                )
                .padding(.horizontal, 41)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            } else {
                ReviewButton()
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: viewModel.showsSuggestions)
    }
}

#Preview {
    AmountEntryView()
}
