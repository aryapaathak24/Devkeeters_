//
//  MenuAdvisorServiceTests.swift
//  Devkeeters_26Tests
//

import XCTest
@testable import Devkeeters_26

final class MenuAdvisorServiceTests: XCTestCase {
    private let service = MenuAdvisorService()

    private var pizzaVendor: AdvisorVendor {
        service.vendors().first { $0.name == "Pizza Point" }!
    }

    func test_exactComboMatch_returnsCorrectSavings() {
        let vendor = pizzaVendor
        let cart = vendor.items.filter { ["Margherita Pizza", "Garlic Bread", "Coke 500ml"].contains($0.name) }

        let combo = service.bestCombo(forCart: cart, at: vendor)

        XCTAssertEqual(combo?.name, "Pizza Meal Combo")
        XCTAssertEqual(combo.map { $0.savings(in: vendor.items) }, 50)
    }

    func test_belowThresholdSavings_isSuppressed() {
        let vendor = service.vendors().first { $0.name == "Chai Point" }!
        let cart = vendor.items.filter { ["Masala Chai", "Samosa"].contains($0.name) }

        XCTAssertNil(service.bestCombo(forCart: cart, at: vendor))
    }

    func test_multipleQualifyingCombos_returnsOnlyBest() {
        let vendor = pizzaVendor
        // Full cart qualifies both "Pizza Meal Combo" (₹50 savings) and
        // "Pizza + Cake Combo" (₹40 savings) — only the best should return.
        let combo = service.bestCombo(forCart: vendor.items, at: vendor)

        XCTAssertEqual(combo?.name, "Pizza Meal Combo")
    }

    func test_vendorWithNoCombos_returnsNilWithoutThrowing() {
        let vendor = AdvisorVendor(
            name: "No Combo Cafe",
            cuisineEmoji: "☕",
            items: [AdvisorMenuItem(name: "Coffee", emoji: "☕", price: 50)],
            combos: []
        )

        XCTAssertNil(service.bestCombo(forCart: vendor.items, at: vendor))
    }
}
