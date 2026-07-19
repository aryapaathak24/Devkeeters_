//
//  MenuAdvisorService.swift
//  Devkeeters_26
//
//  Combo-savings calculation: cart matches a combo's required items -> the
//  single highest-savings qualifying combo is surfaced, gated by a minimum
//  savings threshold so trivial savings don't produce a spammy banner
//  (edge cases from 07_menu_pricing_advisor.json).
//

import Foundation

protocol MenuAdvisorProviding {
    func vendors() -> [AdvisorVendor]
    func bestCombo(forCart cart: [AdvisorMenuItem], at vendor: AdvisorVendor) -> ComboDeal?
}

struct MenuAdvisorService: MenuAdvisorProviding {
    static let minimumSavingsThreshold = 15

    private static let seedVendors: [AdvisorVendor] = [
        AdvisorVendor(
            name: "Pizza Point",
            cuisineEmoji: "🍕",
            items: [
                AdvisorMenuItem(name: "Margherita Pizza", emoji: "🍕", price: 260),
                AdvisorMenuItem(name: "Garlic Bread", emoji: "🥖", price: 90),
                AdvisorMenuItem(name: "Coke 500ml", emoji: "🥤", price: 60),
                AdvisorMenuItem(name: "Choco Lava Cake", emoji: "🍫", price: 110)
            ],
            combos: [
                ComboDeal(name: "Pizza Meal Combo", includedItemNames: ["Margherita Pizza", "Garlic Bread", "Coke 500ml"], comboPrice: 360),
                ComboDeal(name: "Pizza + Cake Combo", includedItemNames: ["Margherita Pizza", "Choco Lava Cake"], comboPrice: 330)
            ]
        ),
        AdvisorVendor(
            name: "Burger Barn",
            cuisineEmoji: "🍔",
            items: [
                AdvisorMenuItem(name: "Classic Burger", emoji: "🍔", price: 150),
                AdvisorMenuItem(name: "Fries", emoji: "🍟", price: 80),
                AdvisorMenuItem(name: "Cold Coffee", emoji: "🥤", price: 90),
                AdvisorMenuItem(name: "Onion Rings", emoji: "🧅", price: 70)
            ],
            combos: [
                ComboDeal(name: "Burger Meal Combo", includedItemNames: ["Classic Burger", "Fries", "Cold Coffee"], comboPrice: 270)
            ]
        ),
        AdvisorVendor(
            name: "Chai Point",
            cuisineEmoji: "🫖",
            items: [
                AdvisorMenuItem(name: "Masala Chai", emoji: "🫖", price: 30),
                AdvisorMenuItem(name: "Samosa", emoji: "🥟", price: 25),
                AdvisorMenuItem(name: "Bun Maska", emoji: "🥐", price: 40),
                AdvisorMenuItem(name: "Cutting Chai", emoji: "☕", price: 20)
            ],
            combos: [
                // Below minimumSavingsThreshold on purpose — exercises the
                // "trivial saving suppressed" edge case.
                ComboDeal(name: "Chai-Samosa Combo", includedItemNames: ["Masala Chai", "Samosa"], comboPrice: 45)
            ]
        )
    ]

    func vendors() -> [AdvisorVendor] { Self.seedVendors }

    func bestCombo(forCart cart: [AdvisorMenuItem], at vendor: AdvisorVendor) -> ComboDeal? {
        let cartNames = Set(cart.map(\.name))
        return vendor.combos
            .filter { Set($0.includedItemNames).isSubset(of: cartNames) }
            .map { ($0, $0.savings(in: vendor.items)) }
            .filter { $0.1 >= Self.minimumSavingsThreshold }
            .max { $0.1 < $1.1 }?
            .0
    }
}
