//
//  PurchaseHistoryModels.swift
//  Devkeeters_26
//
//  Purchase history feeding the Predicting Baskets interval-averaging
//  heuristic — see 03_predictive_baskets.json.
//

import Foundation

struct PurchaseRecord: Codable, Identifiable {
    let id: UUID
    var itemName: String
    var date: Date
    var price: Int

    init(id: UUID = UUID(), itemName: String, date: Date, price: Int) {
        self.id = id
        self.itemName = itemName
        self.date = date
        self.price = price
    }
}
