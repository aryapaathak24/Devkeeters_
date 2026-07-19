//
//  GetNightHelpIntent.swift
//  Devkeeters_26
//
//  Read-only Siri entry point for Night Emergency Mode — speaks the
//  nearest open vendor(s) rather than placing an order, matching
//  OrderMyUsualIntent's dialog-building style but with no side effect.
//  Registered in Ordering/CortexShortcuts.swift.
//

import AppIntents
import Foundation

struct GetNightHelpIntent: AppIntent {
    static var title: LocalizedStringResource = "Night Help"
    static var description = IntentDescription("Finds what's open right now nearby through Cortex's Night Emergency Mode.")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = NightModeService()
        let vendors = service.vendors(withinKm: NightModeViewModel.maxRadiusKm, category: nil, at: Date())

        guard let nearest = vendors.first else {
            return .result(dialog: "Nothing seems to be open nearby right now.")
        }

        var dialog = "\(nearest.name) is open now, \(nearest.etaMinutes) minutes away."
        let others = vendors.dropFirst().prefix(2)
        if !others.isEmpty {
            dialog += " Also open: \(others.map(\.name).joined(separator: ", "))."
        }
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}
