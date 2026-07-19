//
//  CheckPantryIntent.swift
//  Devkeeters_26
//
//  Read-only Siri entry point — speaks what's running low.
//  Registered in Ordering/CortexShortcuts.swift.
//

import AppIntents

struct CheckPantryIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Pantry"
    static var description = IntentDescription("Reads out what's running low in your pantry through Cortex's PantryLens.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let items = PantryStore.shared.load()
        guard !items.isEmpty else {
            return .result(dialog: "You haven't scanned anything into your pantry yet.")
        }

        let low = PantryLowStockEngine.grouped(items).lowStock
        guard !low.isEmpty else {
            return .result(dialog: "You're well stocked on everything right now.")
        }

        let names = low.prefix(5).map(\.name).joined(separator: ", ")
        return .result(dialog: IntentDialog(stringLiteral: "You're running low on \(names)."))
    }
}
