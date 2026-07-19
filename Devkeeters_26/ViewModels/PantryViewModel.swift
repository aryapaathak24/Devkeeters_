//
//  PantryViewModel.swift
//  Devkeeters_26
//
//  Bridges PantryStore + PantryLowStockEngine to the Pantry screens.
//

import Foundation

@MainActor
@Observable
final class PantryViewModel {
    private let store: PantryStore

    private(set) var lowStockItems: [PantryItem] = []
    private(set) var wellStockedItems: [PantryItem] = []

    init(store: PantryStore = .shared) {
        self.store = store
        refresh()
    }

    var isEmpty: Bool { lowStockItems.isEmpty && wellStockedItems.isEmpty }

    func refresh() {
        let grouped = PantryLowStockEngine.grouped(store.load())
        lowStockItems = grouped.lowStock
        wellStockedItems = grouped.wellStocked
    }

    func confirmScanReview(_ lineItems: [ReceiptLineItem]) {
        let items = lineItems.map { line in
            PantryItem(name: line.name, category: Self.guessCategory(for: line.name), estimatedQuantity: max(line.quantity, 1), lastSeenDate: Date())
        }
        store.upsert(items)
        refresh()
    }

    func addManualItem(name: String, category: PantryCategory, quantity: Int, unit: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.upsert([PantryItem(name: name, category: category, estimatedQuantity: quantity, unit: unit, lastSeenDate: Date())])
        refresh()
    }

    func markOut(_ item: PantryItem) {
        var updated = item
        updated.estimatedQuantity = 0
        store.update(updated)
        refresh()
    }

    func editQuantity(_ item: PantryItem, quantity: Int) {
        var updated = item
        updated.estimatedQuantity = max(0, quantity)
        store.update(updated)
        refresh()
    }

    func deleteItem(_ item: PantryItem) {
        store.delete(item)
        refresh()
    }

    private static func guessCategory(for name: String) -> PantryCategory {
        let lower = name.lowercased()
        if ["milk", "cheese", "yogurt", "curd", "butter", "paneer"].contains(where: lower.contains) { return .dairy }
        if ["bread", "bun", "bagel", "naan"].contains(where: lower.contains) { return .bakery }
        if ["rice", "flour", "sugar", "salt", "oil", "dal", "lentil", "pasta"].contains(where: lower.contains) { return .staple }
        if ["vegetable", "fruit", "tomato", "onion", "potato", "produce"].contains(where: lower.contains) { return .produce }
        return .other
    }
}
