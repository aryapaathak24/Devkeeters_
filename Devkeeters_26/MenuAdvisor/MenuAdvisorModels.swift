//
//  MenuAdvisorModels.swift
//  Devkeeters_26
//
//  Models for the consumer combo-value flag — see
//  07_menu_pricing_advisor.json. Deliberately its own menu/vendor source,
//  distinct from ZomatoService's private menu dict and ManageUsualView's
//  MenuItem.all — a third, independent mock catalog, not a shared one.
//

import Foundation

struct AdvisorMenuItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var emoji: String
    var price: Int
}

struct ComboDeal: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var includedItemNames: [String]
    var comboPrice: Int

    func individualPrice(in items: [AdvisorMenuItem]) -> Int {
        includedItemNames.compactMap { name in items.first { $0.name == name }?.price }.reduce(0, +)
    }

    func savings(in items: [AdvisorMenuItem]) -> Int {
        individualPrice(in: items) - comboPrice
    }
}

struct AdvisorVendor: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var cuisineEmoji: String
    var items: [AdvisorMenuItem]
    var combos: [ComboDeal]
}
