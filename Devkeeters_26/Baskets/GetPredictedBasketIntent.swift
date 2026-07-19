//
//  GetPredictedBasketIntent.swift
//  Devkeeters_26
//
//  Read-only Siri entry point — speaks this week's predicted basket.
//  Registered in Ordering/CortexShortcuts.swift.
//

import AppIntents

struct GetPredictedBasketIntent: AppIntent {
    static var title: LocalizedStringResource = "Predicted Basket"
    static var description = IntentDescription("Reads out this week's predicted grocery basket from Cortex.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let historyStore = PurchaseHistoryStore.shared
        historyStore.seedIfNeeded()

        let predicted = BasketPredictionEngine.predict(from: historyStore.load())
        let items = predicted.isEmpty ? BasketStarterTemplate.items : predicted
        let total = items.map(\.estimatedPrice).reduce(0, +)
        let names = items.prefix(4).map(\.name).joined(separator: ", ")

        let dialog = "Your basket has \(items.count) items — \(names) — totaling ₹\(total)."
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
