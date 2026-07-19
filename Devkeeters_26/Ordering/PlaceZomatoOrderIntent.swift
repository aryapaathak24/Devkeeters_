//
//  PlaceZomatoOrderIntent.swift
//  Devkeeters_26
//
//  Siri's entry point for the Zomato flow. Fixed phrase + free-text item
//  (see CortexShortcuts). Delegates entirely to OrderingCoordinator —
//  the same function the touch fallback calls.
//

import AppIntents

struct PlaceZomatoOrderIntent: AppIntent {
    static var title: LocalizedStringResource = "Order Food"
    static var description = IntentDescription("Places a mock Zomato food order through Cortex.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Order", requestValueDialog: "What would you like to order?")
    var orderText: String

    static var parameterSummary: some ParameterSummary {
        Summary("Order \(\.$orderText)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let summary = try await OrderingCoordinator.shared.placeOrder(from: orderText)
            return .result(dialog: "Placing your order for \(summary.title). I'll keep you posted on the status.")
        } catch let error as OrderingCoordinatorError {
            return .result(dialog: IntentDialog(stringLiteral: error.errorDescription ?? "Sorry, I couldn't place that order."))
        } catch {
            return .result(dialog: "Sorry, I couldn't place that order.")
        }
    }
}
