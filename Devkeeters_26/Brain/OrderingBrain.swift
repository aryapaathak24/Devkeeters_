//
//  OrderingBrain.swift
//  Devkeeters_26
//
//  The single shared reasoning layer. Built once, called from every entry
//  point (voice, camera, touch) — see 01_BRAIN.md. Not recreated per request.
//
//  On Simulator: simple keyword-matching mock (no FoundationModels).
//  On Device:    Apple Intelligence via FoundationModels.
//

#if targetEnvironment(simulator)

import CoreGraphics
import Foundation

// ── Simulator mock ────────────────────────────────────────────────────────
// Splits text on "and" / commas, detects domain by keyword, returns a
// RoutedIntent without any AI. Fast, offline, zero dependencies.

final class OrderingBrain {
    static let shared = OrderingBrain()
    private init() {}

    private static let groceryKeywords = ["milk", "eggs", "bread", "butter",
        "sugar", "salt", "rice", "flour", "vegetables", "fruit", "water",
        "juice", "cereal", "snacks", "chips", "chocolate", "beer", "wine"]

    private static let eventKeywords = ["ticket", "concert", "movie", "show",
        "event", "booking", "match", "game", "play", "exhibition", "festival"]

    func route(text: String) async throws -> RoutedIntent {
        let lower = text.lowercased()

        // Detect domain by keyword scan
        let domain: ServiceDomain
        if Self.groceryKeywords.contains(where: { lower.contains($0) }) {
            domain = .blinkit
        } else if Self.eventKeywords.contains(where: { lower.contains($0) }) {
            domain = .district
        } else {
            domain = .zomato   // default: food order
        }

        // Split "butter chicken and naan" → ["butter chicken", "naan"]
        let separators = CharacterSet(charactersIn: ",")
        let parts = text
            .components(separatedBy: " and ")
            .flatMap { $0.components(separatedBy: separators) }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return RoutedIntent(domain: domain, summary: text, items: parts, secondaryAction: nil)
    }

    // Camera path not needed in Simulator — stub satisfies the protocol.
    func route(image: CGImage) async throws -> RoutedIntent {
        RoutedIntent(domain: .zomato, summary: "photo order", items: ["biryani"], secondaryAction: nil)
    }
}

#else

// ── Device ── Apple Intelligence ──────────────────────────────────────────
import CoreGraphics
import FoundationModels

final class OrderingBrain {
    static let shared = OrderingBrain()

    private let pendingImage = PendingImage()
    private let session: LanguageModelSession

    private init() {
        session = LanguageModelSession(
            tools: [OCRTool(pendingImage: pendingImage), BarcodeReaderTool(pendingImage: pendingImage)],
            instructions: """
            You route requests to one of three mock services: zomato (food \
            ordering), blinkit (groceries), or district (event booking).

            Given text or a photo, decide which domain the request belongs \
            to, write a plain-language summary, and extract concrete items \
            (dish names, grocery items, or event names).

            Only set secondaryAction if the request clearly implies a second \
            domain as well — for example, "friends over Friday" implies both \
            a district booking and a blinkit party cart. Leave it nil for a \
            request that only touches one domain.

            When given a photo, call readTextFromImage or readBarcodeFromImage \
            to see what's in it before deciding — you have no other way to \
            read the image.
            """
        )
    }

    func route(text: String) async throws -> RoutedIntent {
        let response = try await session.respond(to: text, generating: RoutedIntent.self)
        return response.content
    }

    func route(image: CGImage) async throws -> RoutedIntent {
        pendingImage.set(image)
        defer { pendingImage.set(nil) }
        let response = try await session.respond(
            to: "A photo has just been captured. Read it with your tools and route it.",
            generating: RoutedIntent.self
        )
        return response.content
    }
}

#endif
