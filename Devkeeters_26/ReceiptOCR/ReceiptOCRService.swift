//
//  ReceiptOCRService.swift
//  Devkeeters_26
//
//  Standalone receipt-photo OCR, shared by PantryLens (receipt_import) and
//  Predicting Baskets' Smart Reading (order_history_import). Unlike
//  Brain/OCRTool.swift (a FoundationModels Tool only callable from inside
//  OrderingBrain's LanguageModelSession), this runs Vision directly so it
//  works standalone — and, per "heuristics before ML," parses lines with a
//  plain regex, not a receipt-parsing model.
//
//  On Simulator: returns a canned parsed receipt (no camera, no Vision).
//  On Device:    VNRecognizeTextRequest + naive name/price line parsing.
//

import CoreGraphics
import Foundation

enum OCRConfidence: Equatable {
    case high, medium, low
}

struct ReceiptLineItem: Identifiable {
    let id = UUID()
    var name: String
    var price: Int?
    var quantity: Int = 1
    var confidence: OCRConfidence
}

protocol ReceiptScanning {
    func scanReceipt(image: CGImage) async throws -> [ReceiptLineItem]
}

struct ReceiptOCRService: ReceiptScanning {

    func scanReceipt(image: CGImage) async throws -> [ReceiptLineItem] {
        #if targetEnvironment(simulator)
        return Self.simulatorCannedReceipt
        #else
        let lines = try Self.recognizeLines(in: image)
        return Self.parse(lines: lines)
        #endif
    }

    #if !targetEnvironment(simulator)
    private static func recognizeLines(in image: CGImage) throws -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
        return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
    }
    #endif

    // MARK: - Parsing

    private static let noiseKeywords = [
        "total", "subtotal", "tax", "cgst", "sgst", "gst", "cash", "change",
        "card", "visa", "mastercard", "thank you", "invoice", "bill no",
        "date", "time", "qty", "receipt"
    ]

    /// name + trailing price → high confidence. Name only (no parseable
    /// price) → low confidence, flagged for manual confirm rather than
    /// silently dropped or guessed at.
    static func parse(lines: [String]) -> [ReceiptLineItem] {
        let priceRegex = try? NSRegularExpression(
            pattern: #"^(.+?)\s+(?:₹|Rs\.?|INR)?\s*(\d{1,5}(?:\.\d{1,2})?)\s*$"#,
            options: [.caseInsensitive]
        )

        var items: [ReceiptLineItem] = []
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }

            let lower = line.lowercased()
            if noiseKeywords.contains(where: { lower.contains($0) }) { continue }

            let fullRange = NSRange(line.startIndex..<line.endIndex, in: line)
            if let match = priceRegex?.firstMatch(in: line, options: [], range: fullRange),
               let nameRange = Range(match.range(at: 1), in: line),
               let priceRange = Range(match.range(at: 2), in: line),
               let price = Double(line[priceRange]) {
                let name = String(line[nameRange]).trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { continue }
                items.append(ReceiptLineItem(name: name, price: Int(price.rounded()), confidence: .high))
            } else {
                items.append(ReceiptLineItem(name: line, price: nil, confidence: .low))
            }
        }
        return items
    }

    // MARK: - Simulator canned result

    private static let simulatorCannedReceipt: [ReceiptLineItem] = [
        ReceiptLineItem(name: "Milk 1L", price: 45, confidence: .high),
        ReceiptLineItem(name: "Bread", price: 40, confidence: .high),
        ReceiptLineItem(name: "Eggs (12)", price: 90, confidence: .high),
        ReceiptLineItem(name: "Rice 5kg", price: 320, confidence: .medium),
        ReceiptLineItem(name: "Unbranded Produce", price: nil, confidence: .low)
    ]
}

#if !targetEnvironment(simulator)
import Vision
#endif
