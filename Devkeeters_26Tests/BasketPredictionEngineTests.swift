//
//  BasketPredictionEngineTests.swift
//  Devkeeters_26Tests
//

import XCTest
@testable import Devkeeters_26

final class BasketPredictionEngineTests: XCTestCase {

    func test_consistentInterval_isIncludedWithHighConfidence() {
        let calendar = Calendar.current
        let now = Date()
        var records: [PurchaseRecord] = []
        var date = now
        for _ in 0..<6 {
            records.append(PurchaseRecord(itemName: "Milk", date: date, price: 45))
            date = calendar.date(byAdding: .day, value: -7, to: date)!
        }

        let predicted = BasketPredictionEngine.predict(from: records, asOf: now)
        let milk = predicted.first { $0.name == "Milk" }

        XCTAssertNotNil(milk)
        XCTAssertEqual(milk?.confidence, .high)
    }

    func test_highVarianceInterval_isExcluded() {
        let calendar = Calendar.current
        let now = Date()
        var records: [PurchaseRecord] = []
        var date = now
        for gap in [2, 40, 3, 35] {
            records.append(PurchaseRecord(itemName: "Chocolate", date: date, price: 60))
            date = calendar.date(byAdding: .day, value: -gap, to: date)!
        }
        records.append(PurchaseRecord(itemName: "Chocolate", date: date, price: 60))

        let predicted = BasketPredictionEngine.predict(from: records, asOf: now)

        XCTAssertNil(predicted.first { $0.name == "Chocolate" })
    }

    func test_fewerThanThreeRecords_isExcluded() {
        let now = Date()
        let records = [
            PurchaseRecord(itemName: "Rice", date: now, price: 320),
            PurchaseRecord(itemName: "Rice", date: Calendar.current.date(byAdding: .day, value: -20, to: now)!, price: 320)
        ]

        XCTAssertTrue(BasketPredictionEngine.predict(from: records, asOf: now).isEmpty)
    }

    func test_emptyHistory_returnsEmptyResult() {
        XCTAssertTrue(BasketPredictionEngine.predict(from: []).isEmpty)
    }
}
