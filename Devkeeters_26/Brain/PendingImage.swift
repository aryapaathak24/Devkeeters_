//
//  PendingImage.swift
//  Devkeeters_26
//
//  The on-device model is text-only; it can't see a photo directly. When
//  OrderingBrain.route(image:) runs, it stashes the photo here first, then
//  prompts the model to call OCRTool/BarcodeReaderTool, which read it from
//  this shared holder. Scoped to the brain's own session, not app-wide state.
//

import CoreGraphics

final class PendingImage: @unchecked Sendable {
    private let lock = NSLock()
    private var image: CGImage?

    func set(_ image: CGImage?) {
        lock.lock()
        defer { lock.unlock() }
        self.image = image
    }

    func get() -> CGImage? {
        lock.lock()
        defer { lock.unlock() }
        return image
    }
}
