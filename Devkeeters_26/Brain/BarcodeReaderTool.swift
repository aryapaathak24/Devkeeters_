//
//  BarcodeReaderTool.swift
//  Devkeeters_26
//
//  Vision-backed. The model decides when to call this; the app never reads
//  barcodes manually (see 01_BRAIN.md).
//

import FoundationModels
import Vision

struct BarcodeReaderTool: Tool {
    let name = "readBarcodeFromImage"
    let description = "Detects and returns any barcode or QR code payloads visible in the photo currently being processed."

    let pendingImage: PendingImage

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> ToolOutput {
        guard let image = pendingImage.get() else {
            return ToolOutput("No image is currently available to read.")
        }

        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])

        let payloads = (request.results ?? [])
            .compactMap { $0.payloadStringValue }

        guard !payloads.isEmpty else {
            return ToolOutput("No barcode was found in the image.")
        }
        return ToolOutput(payloads.joined(separator: "\n"))
    }
}
