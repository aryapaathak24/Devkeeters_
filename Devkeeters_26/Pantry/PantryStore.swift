//
//  PantryStore.swift
//  Devkeeters_26
//
//  Same UserDefaults + Codable idiom as Models/LastOrderStore.swift.
//  Deliberately NOT pre-seeded — unlike Baskets' PurchaseHistoryStore,
//  PantryLens should show a true empty first-run state until the user
//  actually scans something.
//

import Foundation

final class PantryStore {
    static let shared = PantryStore()
    private init() {}

    private let key = "com.devkeeters.pantryItems"

    func load() -> [PantryItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([PantryItem].self, from: data) else {
            return []
        }
        return items
    }

    func save(_ items: [PantryItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// Merges by case-insensitive name: an existing item's quantity is
    /// bumped and its lastSeenDate refreshed rather than duplicated.
    func upsert(_ newItems: [PantryItem]) {
        var current = load()
        for newItem in newItems {
            if let index = current.firstIndex(where: { $0.name.caseInsensitiveCompare(newItem.name) == .orderedSame }) {
                current[index].estimatedQuantity += newItem.estimatedQuantity
                current[index].lastSeenDate = newItem.lastSeenDate
            } else {
                current.append(newItem)
            }
        }
        save(current)
    }

    func update(_ item: PantryItem) {
        var current = load()
        guard let index = current.firstIndex(where: { $0.id == item.id }) else { return }
        current[index] = item
        save(current)
    }

    func delete(_ item: PantryItem) {
        save(load().filter { $0.id != item.id })
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
