//
//  OCRTool.swift
//  Devkeeters_26
//
//  Vision-backed. The model decides when to call this; the app never runs
//  OCR manually (see 01_BRAIN.md).
//

import FoundationModels
import Vision

struct OCRTool: Tool {
    let name = "readTextFromImage"
    let description = "Reads and returns all visible text from the photo currently being processed, such as a handwritten or printed grocery list."

    let pendingImage: PendingImage

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        guard let image = pendingImage.get() else {
            return "No image is currently available to read."
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])

        let lines = (request.results ?? [])
            .compactMap { $0.topCandidates(1).first?.string }

        guard !lines.isEmpty else {
            return "No text was found in the image."
        }
        return lines.joined(separator: "\n")
    }
}
