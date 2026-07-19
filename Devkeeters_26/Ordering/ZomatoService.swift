//
//  ZomatoService.swift
//  Devkeeters_26
//
//  Mock Zomato food-ordering domain service. Turns the brain's RoutedIntent
//  into an OrderSummary the shared Live Activity can render. No real Zomato
//  API — everything here is canned/synthesized demo data.
//
//  Now includes:
//  • Per-item pricing (₹)
//  • Demo restaurant pool (rotates by time-of-day)
//  • Availability check (90% available, 1 item unavailable per session)
//

import Foundation

// MARK: - Protocol

protocol ZomatoOrdering {
    func buildOrderSummary(from routed: RoutedIntent) -> OrderSummary
    func buildOrderSummary(from items: [String], restaurant: String) -> OrderSummary
    func checkAvailability(for items: [String]) -> [String: Bool]
}

// MARK: - Service

struct ZomatoService: ZomatoOrdering {

    // MARK: Demo Menu — (prepMinutes, priceRupees)
    private static let menu: [String: (mins: Int, price: Int)] = [
        "butter chicken": (28, 280),
        "naan":           (10,  60),
        "biryani":        (35, 320),
        "paneer tikka":   (22, 220),
        "pizza":          (25, 350),
        "burger":         (18, 180),
        "pasta":          (20, 240),
        "dosa":           (15,  90),
        "noodles":        (18, 160),
        "fried rice":     (18, 140),
        "sushi":          (30, 480),
        "salad":          (12, 120),
        "sandwich":       (10, 110),
        "dal makhani":    (25, 190),
        "garlic naan":    (12,  70),
        "masala chai":    ( 5,  40)
    ]

    private static let defaultMins  = 25
    private static let defaultPrice = 200
    private static let deliveryBuffer = 12

    // MARK: Demo Restaurants (rotates every 4 hours so it feels live)
    private static let restaurants = [
        "Spice Garden", "The Curry House", "Biryani Bros",
        "Delhi Darbar", "Urban Tadka"
    ]

    private static var currentRestaurant: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return restaurants[(hour / 4) % restaurants.count]
    }

    // MARK: Unavailable Item Simulation
    // One menu item is "unavailable" per session (rotates hourly).
    private static var unavailableItem: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let keys = Array(menu.keys)
        return keys[hour % keys.count]
    }

    // MARK: - Protocol Conformance

    /// Build summary from a brain-routed intent (voice / touch entry).
    func buildOrderSummary(from routed: RoutedIntent) -> OrderSummary {
        let items = routed.items.isEmpty ? [routed.summary] : routed.items
        let restaurant = Self.currentRestaurant
        return buildOrderSummary(from: items, restaurant: restaurant)
    }

    /// Build summary from an explicit item list + restaurant (reorder path).
    func buildOrderSummary(from items: [String], restaurant: String) -> OrderSummary {
        let totalPrice = items.map { price(for: $0) }.reduce(0, +)
        let maxPrep    = items.map { prepMinutes(for: $0) }.max() ?? Self.defaultMins
        let eta        = maxPrep + Self.deliveryBuffer

        return OrderSummary(
            domain:         .zomato,
            title:          items.joined(separator: ", "),
            items:          items,
            restaurantName: restaurant,
            totalPrice:     totalPrice,
            initialStatus:  "Order placed",
            etaMinutes:     eta
        )
    }

    /// Returns a map of item → available for a given list.
    /// ~90% available; one specific item per hour is marked unavailable.
    func checkAvailability(for items: [String]) -> [String: Bool] {
        let blockedItem = Self.unavailableItem
        return Dictionary(uniqueKeysWithValues: items.map { item in
            let unavailable = item.lowercased().contains(blockedItem)
            return (item, !unavailable)
        })
    }

    // MARK: - Helpers

    private func prepMinutes(for item: String) -> Int {
        let lowered = item.lowercased()
        return Self.menu.first { lowered.contains($0.key) }?.value.mins ?? Self.defaultMins
    }

    private func price(for item: String) -> Int {
        let lowered = item.lowercased()
        return Self.menu.first { lowered.contains($0.key) }?.value.price ?? Self.defaultPrice
    }
}
