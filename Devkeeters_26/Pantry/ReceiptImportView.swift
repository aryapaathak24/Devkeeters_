//
//  ReceiptImportView.swift
//  Devkeeters_26
//
//  receipt_import screen — camera/library entry point feeding scan_review.
//  Uses the shared ReceiptOCR/ReceiptOCRService, same as Smart Reading's
//  order_history_import.
//

import SwiftUI

struct ReceiptImportView: View {
    let viewModel: PantryViewModel

    @State private var showCapture = false
    @State private var isLoading = false
    @State private var scannedItems: [ReceiptLineItem]?

    @Environment(\.dismiss) private var dismiss
    private let ocrService = ReceiptOCRService()

    var body: some View {
        Group {
            if let scannedItems {
                ScanReviewView(items: scannedItems) { confirmed in
                    viewModel.confirmScanReview(confirmed)
                    dismiss()
                }
            } else if isLoading {
                ProgressView("Reading your photo…")
                    .tint(Color.theme.primary)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.theme.primary)
                    Text("Scan a receipt")
                        .font(.theme.headlineMd)
                        .foregroundStyle(Color.theme.onSurface)
                    Button("Scan Receipt") { showCapture = true }
                        .buttonStyle(.themePrimary)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.theme.background)
        .navigationTitle("Receipt Import")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .sheet(isPresented: $showCapture) {
            ReceiptCaptureView { image in
                Task {
                    isLoading = true
                    scannedItems = (try? await ocrService.scanReceipt(image: image)) ?? []
                    isLoading = false
                }
            }
        }
    }
}
