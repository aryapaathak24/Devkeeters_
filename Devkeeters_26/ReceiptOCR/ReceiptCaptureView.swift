//
//  ReceiptCaptureView.swift
//  Devkeeters_26
//
//  Reusable receipt capture UI shared by PantryLens (receipt_import) and
//  Smart Reading (order_history_import) — camera when available, else a
//  PHPickerViewController library pick (no Info.plist key needed for that
//  path). On Simulator (no camera, possibly-empty photo library) it skips
//  straight to a "simulate scan" action so the flow stays demoable —
//  ReceiptOCRService's Simulator branch returns a canned result regardless
//  of the image passed in.
//

import SwiftUI
import UIKit
import PhotosUI

struct ReceiptCaptureView: View {
    var onCapture: (CGImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showCamera = false
    @State private var showLibraryPicker = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(Color.theme.primary)

            Text("Scan a receipt")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)

            Text("We'll read the line items automatically.")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            #if targetEnvironment(simulator)
            Button("Simulate Receipt Scan") {
                if let image = Self.placeholderCGImage() { onCapture(image) }
                dismiss()
            }
            .buttonStyle(.themePrimary)
            #else
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") { showCamera = true }
                    .buttonStyle(.themePrimary)
            }
            Button("Choose from Library") { showLibraryPicker = true }
                .buttonStyle(.themeSecondary)
            #endif

            Button("Cancel", role: .cancel) { dismiss() }
                .tint(Color.theme.onSurfaceVariant)
                .padding(.top, 4)
        }
        .padding(24)
        .background(Color.theme.background)
        #if !targetEnvironment(simulator)
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in handle(image) }
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showLibraryPicker) {
            LibraryPicker { image in
                if let image { handle(image) }
            }
        }
        #endif
    }

    private func handle(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        onCapture(cgImage)
        dismiss()
    }

    private static func placeholderCGImage() -> CGImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return image.cgImage
    }
}

#if !targetEnvironment(simulator)
private struct CameraPicker: UIViewControllerRepresentable {
    var onImage: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImage: (UIImage) -> Void
        init(onImage: @escaping (UIImage) -> Void) { self.onImage = onImage }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { onImage(image) }
        }
    }
}

private struct LibraryPicker: UIViewControllerRepresentable {
    var onImage: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImage: (UIImage?) -> Void
        init(onImage: @escaping (UIImage?) -> Void) { self.onImage = onImage }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                onImage(nil)
                return
            }
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async { self.onImage(object as? UIImage) }
            }
        }
    }
}
#endif
        
















