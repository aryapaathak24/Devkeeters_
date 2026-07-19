//
//  PantryLowStockEngine.swift
//  Devkeeters_26
//
//  Groups pantry items into low-stock / well-stocked using each item's
//  predictedRunOutDate (category default window, per PantryModels.swift)
//  — a static per-category table, not a purchase-history heuristic, per
//  "heuristics before ML."
//

import Foundation

enum PantryLowStockEngine {
    /// Items whose predicted run-out is already past or within this many
    /// days count as low stock.
    static let lowStockLookaheadDays = 2

    static func isLowStock(_ item: PantryItem, asOf date: Date = Date()) -> Bool {
        let threshold = Calendar.current.date(byAdding: .day, value: lowStockLookaheadDays, to: date) ?? date
        return item.predictedRunOutDate <= threshold
    }

    static func grouped(_ items: [PantryItem], asOf date: Date = Date()) -> (lowStock: [PantryItem], wellStocked: [PantryItem]) {
        let low = items.filter { isLowStock($0, asOf: date) }
        let well = items.filter { !isLowStock($0, asOf: date) }
        return (
            low.sorted { $0.predictedRunOutDate < $1.predictedRunOutDate },
            well.sorted { $0.name < $1.name }
        )
    }
}
