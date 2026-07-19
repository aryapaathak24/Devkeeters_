//
//  ReceiptOCRServiceTests.swift
//  Devkeeters_26Tests
//

import XCTest
@testable import Devkeeters_26

final class ReceiptOCRServiceTests: XCTestCase {

    func test_cleanNameAndPriceLine_parsesWithHighConfidence() {
        let items = ReceiptOCRService.parse(lines: ["Milk 1L 45"])

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Milk 1L")
        XCTAssertEqual(items.first?.price, 45)
        XCTAssertEqual(items.first?.confidence, .high)
    }

    func test_nameOnlyLine_parsesWithLowConfidenceAndNilPrice() {
        let items = ReceiptOCRService.parse(lines: ["Unbranded Produce"])

        XCTAssertEqual(items.count, 1)
        XCTAssertNil(items.first?.price)
        XCTAssertEqual(items.first?.confidence, .low)
    }

    func test_noiseLine_isFiltered() {
        let items = ReceiptOCRService.parse(lines: ["TOTAL 495.00", "Milk 1L 45"])

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Milk 1L")
    }
}
