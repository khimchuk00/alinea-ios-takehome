import SwiftUI

/// The amount-entry screen — assembles all components and binds them to the
/// view model. Laid out edge-to-edge to mirror the 393×853 Figma frame.
struct AmountEntryView: View {
    @State private var viewModel: AmountEntryViewModel

    init(viewModel: AmountEntryViewModel = AmountEntryViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppColor.background
            TopGlow(isVisible: !viewModel.isEmpty)
            // Pin the content to the screen width so the off-screen top glow
            // (wider than the screen) can't stretch the layout.
            content
                .containerRelativeFrame(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        // Full-bleed to match the Figma frame, which includes its own status bar
        // and home indicator mock. (See StatusBarView for the rationale.)
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .onAppear { Haptics.prepare() }
    }

    private var content: some View {
        VStack(spacing: 0) {
            StatusBarView()

            navigationRow
                .padding(.top, Metrics.Spacing.navTop)
                .padding(.horizontal, Metrics.Inset.nav)

            Spacer().frame(height: Metrics.Spacing.navToAmount)

            AmountDisplayView(isEmpty: viewModel.isEmpty, amountText: viewModel.displayAmount)

            Spacer(minLength: 0)

            swapSlot
                .frame(height: Metrics.Size.swapHeight)

            Spacer().frame(height: Metrics.Spacing.swapToKeypad)

            KeypadView(
                canAddDecimal: viewModel.canAddDecimal,
                onDigit: { viewModel.tapDigit($0) },
                onDecimal: { viewModel.tapDecimal() },
                onBackspace: { viewModel.tapBackspace() }
            )
            .padding(.horizontal, Metrics.Inset.keypad)

            Spacer().frame(height: Metrics.Spacing.keypadToHome)

            HomeIndicatorView()

            Spacer().frame(height: Metrics.Spacing.homeToBottom)
        }
    }

    private var navigationRow: some View {
        ZStack {
            HStack {
                // Back is intentionally non-functional per the brief
                // ("the back button doesn't need to do anything").
                BackButton()
                Spacer()
            }
            AutomatedBadge()
        }
        .frame(height: Metrics.Size.navRowHeight)
    }

    /// The swap slot below the amount: suggestion chips while empty (comment #1),
    /// the Review button once a value is entered, cross-fading between the two
    /// (comment #3).
    @ViewBuilder
    private var swapSlot: some View {
        ZStack {
            if viewModel.showsSuggestions {
                QuickAmountChipsView(
                    amounts: viewModel.suggestions,
                    onSelect: { viewModel.selectSuggestion($0) }
                )
                .padding(.horizontal, Metrics.Inset.chips)
                .transition(.scale(scale: Motion.chipsTransitionScale).combined(with: .opacity))
            } else {
                // Review is intentionally non-functional per the brief.
                ReviewButton()
                    .padding(.horizontal, Metrics.Inset.review)
                    .transition(.scale(scale: Motion.reviewTransitionScale).combined(with: .opacity))
            }
        }
        .animation(Motion.swap, value: viewModel.showsSuggestions)
    }
}

#Preview {
    AmountEntryView(viewModel: AmountEntryViewModel(initialInput: "2000"))
}
