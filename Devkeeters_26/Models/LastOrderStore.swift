//
//  LastOrderStore.swift
//  Devkeeters_26
//
//  Persists the most recent successful order to UserDefaults so
//  OrderMyUsualIntent can replay it without any manual "save my usual" step.
//  Automatically updated by OrderingCoordinator after every successful order.
//

import Foundation

/// The shape stored on disk. Codable so it round-trips through UserDefaults.
struct SavedOrder: Codable {
    var items: [String]         // e.g. ["butter chicken", "naan"]
    var restaurantName: String  // e.g. "Spice Garden"
    var totalPrice: Int         // ₹ total, e.g. 420
    var etaMinutes: Int         // e.g. 40
}

final class LastOrderStore {
    static let shared = LastOrderStore()
    private init() {}

    private let key = "com.devkeeters.lastOrder"

    /// Whether the user has placed at least one order before.
    var hasOrder: Bool { load() != nil }

    /// Persists the summary of a just-completed order.
    func save(_ summary: OrderSummary) {
        let saved = SavedOrder(
            items: summary.items,
            restaurantName: summary.restaurantName,
            totalPrice: summary.totalPrice,
            etaMinutes: summary.etaMinutes ?? 30
        )
        guard let data = try? JSONEncoder().encode(saved) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// Returns the last saved order, or nil if none exists yet.
    func load() -> SavedOrder? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(SavedOrder.self, from: data)
        else { return nil }
        return saved
    }

    /// Clears the saved order (useful for testing).
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
