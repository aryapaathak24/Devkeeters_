//
//  OrderMyUsualIntent.swift
//  Devkeeters_26
//
//  Siri entry point for "Hey Siri, order my Zomato usual from Cortex".
//  Loads the last order from LastOrderStore, runs a demo availability check,
//  then speaks price + ETA back to the user before placing the order.
//
//  Dialogue scenarios:
//  1. No previous order    → tells user to place one first
//  2. All available        → announces restaurant, items, price, ETA
//  3. Some unavailable     → skips unavailable items, adjusts price + ETA
//  4. Nothing available    → apologises, suggests trying later
//

import AppIntents

struct OrderMyUsualIntent: AppIntent {
    static var title: LocalizedStringResource = "Order My Usual on Zomato"
    static var description = IntentDescription(
        "Reorders your last Zomato order through Cortex, checking availability and announcing price and ETA."
    )
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {

        // ── 1. Load last order ────────────────────────────────────────────
        guard let lastOrder = LastOrderStore.shared.load() else {
            return .result(dialog: """
                You haven't placed any orders yet. \
                Open Cortex, order something, and I'll remember it as your usual.
                """)
        }

        let service = ZomatoService()

        // ── 2. Availability check ─────────────────────────────────────────
        let availability = service.checkAvailability(for: lastOrder.items)
        let availableItems   = lastOrder.items.filter { availability[$0] == true }
        let unavailableItems = lastOrder.items.filter { availability[$0] == false }

        // ── 3. Nothing available at all ───────────────────────────────────
        guard !availableItems.isEmpty else {
            let joined = lastOrder.items.joined(separator: " and ")
            return .result(dialog: """
                Sorry! \(joined) \(lastOrder.items.count == 1 ? "is" : "are") \
                not available from \(lastOrder.restaurantName) right now. \
                Try again in a bit.
                """)
        }

        // ── 4. Build order from available items only ──────────────────────
        let summary = service.buildOrderSummary(
            from: availableItems,
            restaurant: lastOrder.restaurantName
        )

        // ── 5. Place the order ────────────────────────────────────────────
        do {
            try OrderingCoordinator.shared.placeOrder(summary: summary)   // sync — no await
        } catch let error as OrderingCoordinatorError {
            // String must be wrapped in IntentDialog when it's a runtime value (not a literal)
            return .result(dialog: IntentDialog(stringLiteral: error.errorDescription ?? "Sorry, I couldn't place that order."))
        }

        // ── 6. Build Siri's spoken reply ──────────────────────────────────
        let itemList  = availableItems.joined(separator: " and ")
        let eta       = summary.etaMinutes ?? 30
        let price     = summary.totalPrice
        let restaurant = summary.restaurantName

        if unavailableItems.isEmpty {
            // All items available
            return .result(dialog: """
                Ordering your usual from \(restaurant): \
                \(itemList) — ₹\(price). \
                Arriving in about \(eta) minutes. I'll track it on your lock screen.
                """)
        } else {
            // Partial order — some items skipped
            let skipped = unavailableItems.joined(separator: " and ")
            return .result(dialog: """
                \(skipped) \(unavailableItems.count == 1 ? "is" : "are") unavailable right now. \
                Ordering \(itemList) from \(restaurant) — ₹\(price). \
                ETA about \(eta) minutes.
                """)
        }
    }
}
