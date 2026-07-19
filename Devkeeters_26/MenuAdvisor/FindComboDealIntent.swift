//
//  FindComboDealIntent.swift
//  Devkeeters_26
//
//  Read-only Siri entry point — speaks the best qualifying combo deal
//  across all vendors. Registered in Ordering/CortexShortcuts.swift.
//

import AppIntents

struct FindComboDealIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Combo Deal"
    static var description = IntentDescription("Finds the best combo deal available right now through Cortex's Menu Advisor.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = MenuAdvisorService()
        let candidates = service.vendors().flatMap { vendor in
            vendor.combos.map { combo in (vendor: vendor, combo: combo, savings: combo.savings(in: vendor.items)) }
        }.filter { $0.savings >= MenuAdvisorService.minimumSavingsThreshold }

        guard let best = candidates.max(by: { $0.savings < $1.savings }) else {
            return .result(dialog: "No combo deals meet the savings bar right now.")
        }

        let dialog = "\(best.vendor.name) has the \(best.combo.name) — save ₹\(best.savings) versus ordering separately."
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
