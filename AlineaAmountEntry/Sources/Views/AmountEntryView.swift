import SwiftUI

/// The amount-entry screen — assembles all components and binds them to the
/// view model. Laid out edge-to-edge to mirror the 393×853 design.
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
        // Full-bleed: the design includes its own status-bar and home-indicator
        // mock. (See StatusBarView for the rationale.)
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .onAppear { Haptics.prepare() }
        #if DEBUG
        .task { await runDemoAutoplay() }
        #endif
    }

    private var content: some View {
        VStack(spacing: 0) {
            StatusBarView()

            navigationRow
                .padding(.top, Metrics.Spacing.navTop)
                .padding(.horizontal, Metrics.Inset.nav)

            Spacer().frame(height: Metrics.Spacing.navToAmount)

            AmountDisplayView(isPlaceholder: viewModel.isPlaceholder,
                              amountText: viewModel.displayAmount)

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
                // Intentionally non-functional — no destination wired up here.
                BackButton()
                Spacer()
            }
            AutomatedBadge()
        }
        .frame(height: Metrics.Size.navRowHeight)
    }

    /// The swap slot below the amount: suggestion chips while empty, the Review
    /// button once a value is entered, cross-fading between the two.
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
                // Intentionally non-functional — no destination wired up here.
                ReviewButton()
                    .padding(.horizontal, Metrics.Inset.review)
                    .transition(.scale(scale: Motion.reviewTransitionScale).combined(with: .opacity))
            }
        }
        .animation(Motion.swap, value: viewModel.showsSuggestions)
    }

    #if DEBUG
    /// `DEMO_AUTOPLAY=1` scripts a walkthrough (empty → suggestion chip → clear →
    /// type a decimal amount) so a smooth demo clip can be recorded without any
    /// UI-test interaction. No effect otherwise; compiled out of release builds.
    @MainActor
    private func runDemoAutoplay() async {
        guard ProcessInfo.processInfo.environment["DEMO_AUTOPLAY"] == "1" else { return }
        func pause(_ seconds: Double) async { try? await Task.sleep(for: .seconds(seconds)) }

        await pause(1.4)                    // empty screen
        viewModel.selectSuggestion(2_000)  // tap a suggestion chip
        await pause(1.6)
        while !viewModel.isPlaceholder {    // backspace until cleared
            viewModel.tapBackspace()
            await pause(0.3)
        }
        await pause(0.9)
        for digit in [1, 2, 3, 4] {         // type "1,234"
            viewModel.tapDigit(digit)
            await pause(0.4)
        }
        viewModel.tapDecimal()              // "."
        await pause(0.4)
        for digit in [5, 6] {               // -> "1,234.56"
            viewModel.tapDigit(digit)
            await pause(0.4)
        }
        await pause(1.8)
    }
    #endif
}

#Preview {
    AmountEntryView(viewModel: AmountEntryViewModel(initialInput: "2000"))
}
