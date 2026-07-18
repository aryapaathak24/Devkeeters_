//
//  OrderingBrain.swift
//  Devkeeters_26
//
//  The single shared reasoning layer. Built once, called from every entry
//  point (voice, camera, touch) — see 01_BRAIN.md. Not recreated per request.
//

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
        let response = try await session.respond(
            to: text,
            generating: RoutedIntent.self
        )
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
