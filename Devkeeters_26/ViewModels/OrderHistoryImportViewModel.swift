//
//  OrderHistoryImportViewModel.swift
//  Devkeeters_26
//
//  Smart Reading — order_history_import screen. Wraps the shared
//  ReceiptOCRService and appends parsed rows as PurchaseRecords.
//

import CoreGraphics
import Foundation

@MainActor
@Observable
final class OrderHistoryImportViewModel {
    private let ocrService: any ReceiptScanning
    private let historyStore: PurchaseHistoryStore

    private(set) var isProcessing = false
    private(set) var importedCount = 0
    private(set) var lastScanItems: [ReceiptLineItem] = []

    init(ocrService: any ReceiptScanning = ReceiptOCRService(), historyStore: PurchaseHistoryStore = .shared) {
        self.ocrService = ocrService
        self.historyStore = historyStore
    }

    func scan(image: CGImage) async {
        isProcessing = true
        defer { isProcessing = false }

        guard let items = try? await ocrService.scanReceipt(image: image) else {
            importedCount = 0
            return
        }

        lastScanItems = items
        let records = items.compactMap { item -> PurchaseRecord? in
            guard let price = item.price else { return nil }
            return PurchaseRecord(itemName: item.name, date: Date(), price: price)
        }
        historyStore.append(records)
        importedCount = records.count
    }
}
