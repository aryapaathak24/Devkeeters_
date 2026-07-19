//
//  BasketPredictionEngine.swift
//  Devkeeters_26
//
//  Interval-averaging heuristic, not ML, per BUILD_PROMPT.md rule 3 and
//  03_predictive_baskets.json's own notes ("build the simple version
//  first"). Groups purchase history by item, computes the mean and
//  coefficient of variation of days-between-purchase, and excludes items
//  with too few records (cold-start) or too-inconsistent intervals
//  (high-variance edge case) rather than guessing at either.
//

import Foundation

enum PredictionConfidence: Hashable {
    case high, medium, starter
}

struct PredictedItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var confidence: PredictionConfidence
    var avgIntervalDays: Double?
    var lastPurchased: Date?
    var estimatedPrice: Int
}

enum BasketPredictionEngine {
    static let minimumRecordsRequired = 3
    static let maxCoefficientOfVariation = 0.5
    static let highConfidenceCoefficientOfVariation = 0.25

    static func predict(from records: [PurchaseRecord], asOf date: Date = Date()) -> [PredictedItem] {
        let grouped = Dictionary(grouping: records, by: \.itemName)
        var results: [PredictedItem] = []

        for (name, itemRecords) in grouped {
            guard itemRecords.count >= minimumRecordsRequired else { continue }

            let sorted = itemRecords.sorted { $0.date < $1.date }
            let gaps = zip(sorted, sorted.dropFirst()).map { $1.date.timeIntervalSince($0.date) / 86_400 }
            guard !gaps.isEmpty else { continue }

            let mean = gaps.reduce(0, +) / Double(gaps.count)
            guard mean > 0 else { continue }

            let variance = gaps.reduce(0) { $0 + pow($1 - mean, 2) } / Double(gaps.count)
            let coefficientOfVariation = variance.squareRoot() / mean
            guard coefficientOfVariation <= maxCoefficientOfVariation else { continue }

            let confidence: PredictionConfidence = coefficientOfVariation < highConfidenceCoefficientOfVariation ? .high : .medium
            guard let last = sorted.last else { continue }

            results.append(PredictedItem(
                name: name,
                confidence: confidence,
                avgIntervalDays: mean,
                lastPurchased: last.date,
                estimatedPrice: last.price
            ))
        }

        return results.sorted { $0.name < $1.name }
    }
}
