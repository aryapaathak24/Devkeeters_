//
//  PredictedBasketViewModel.swift
//  Devkeeters_26
//
//  Bridges BasketPredictionEngine + PurchaseHistoryStore to
//  PredictedBasketHomeView. "Every Sunday the Cloud Function pre-builds
//  your basket" becomes: recomputed from stored history whenever this
//  view appears, since there's no real backend to schedule a job on.
//

import Foundation

@MainActor
@Observable
final class PredictedBasketViewModel {
    private let historyStore: PurchaseHistoryStore

    private(set) var predictedItems: [PredictedItem] = []
    private(set) var isColdStart = false

    init(historyStore: PurchaseHistoryStore = .shared) {
        self.historyStore = historyStore
        historyStore.seedIfNeeded()
        refresh()
    }

    var runningTotal: Int {
        predictedItems.map(\.estimatedPrice).reduce(0, +)
    }

    func refresh(asOf date: Date = Date()) {
        let records = historyStore.load()
        let predicted = BasketPredictionEngine.predict(from: records, asOf: date)
        if predicted.isEmpty {
            isColdStart = true
            predictedItems = BasketStarterTemplate.items
        } else {
            isColdStart = false
            predictedItems = predicted
        }
    }

    func removeItem(_ item: PredictedItem) {
        predictedItems.removeAll { $0.id == item.id }
    }

    func confirmBasket() {
        BasketConfirmationStore.shared.recordConfirmed()
    }

    func skipThisWeek() {
        BasketConfirmationStore.shared.recordSkipped()
    }
}
