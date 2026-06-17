import SwiftUI

@main
struct AlineaAmountEntryApp: App {
    var body: some Scene {
        WindowGroup {
            AmountEntryView(viewModel: Self.makeViewModel())
                .preferredColorScheme(.dark)
        }
    }

    /// In DEBUG builds the `AMOUNT_PREFILL` environment variable seeds the
    /// entered amount, so previews, screenshots and UI tests can launch straight
    /// into a given state. The hook is compiled out of release builds.
    private static func makeViewModel() -> AmountEntryViewModel {
        #if DEBUG
        let prefill = ProcessInfo.processInfo.environment["AMOUNT_PREFILL"] ?? ""
        return AmountEntryViewModel(initialInput: prefill)
        #else
        return AmountEntryViewModel()
        #endif
    }
}
