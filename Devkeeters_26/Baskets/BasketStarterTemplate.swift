//
//  BasketStarterTemplate.swift
//  Devkeeters_26
//
//  Cold-start / prediction-failure fallback — a category-based starter
//  list rather than an empty or broken basket, per
//  03_predictive_baskets.json's edge cases.
//

import Foundation

enum BasketStarterTemplate {
    static let items: [PredictedItem] = [
        PredictedItem(name: "Milk", confidence: .starter, avgIntervalDays: nil, lastPurchased: nil, estimatedPrice: 45),
        PredictedItem(name: "Bread", confidence: .starter, avgIntervalDays: nil, lastPurchased: nil, estimatedPrice: 40),
        PredictedItem(name: "Eggs", confidence: .starter, avgIntervalDays: nil, lastPurchased: nil, estimatedPrice: 90),
        PredictedItem(name: "Rice", confidence: .starter, avgIntervalDays: nil, lastPurchased: nil, estimatedPrice: 320),
        PredictedItem(name: "Vegetables", confidence: .starter, avgIntervalDays: nil, lastPurchased: nil, estimatedPrice: 60)
    ]
}
