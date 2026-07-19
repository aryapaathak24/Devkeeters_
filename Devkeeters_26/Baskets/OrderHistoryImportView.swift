//
//  OrderHistoryImportView.swift
//  Devkeeters_26
//
//  order_history_import screen (Smart Reading). Its JSON-listed entry
//  points (settings_menu, onboarding_prompt) don't have a home in this
//  app, so it's reached from a row inside PredictedBasketHomeView instead
//  — explicitly optional, skippable, per the JSON's empty state copy.
//

import SwiftUI

struct OrderHistoryImportView: View {
    @State private var viewModel = OrderHistoryImportViewModel()
    @State private var showCapture = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundStyle(Color.theme.primary)

            Text("Speed up your predictions")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)

            Text("Scan a few old receipts — totally optional, you can skip this.")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            if viewModel.isProcessing {
                ProgressView("Reading receipt…").tint(Color.theme.primary)
            } else if viewModel.importedCount > 0 {
                Label("Added \(viewModel.importedCount) items to your history", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.theme.success)
            }

            Button("Scan Receipt") { showCapture = true }
                .buttonStyle(.themePrimary)

            Button("Skip", role: .cancel) { dismiss() }
                .tint(Color.theme.onSurfaceVariant)

            Spacer()
        }
        .padding()
        .background(Color.theme.background)
        .sheet(isPresented: $showCapture) {
            ReceiptCaptureView { image in
                Task { await viewModel.scan(image: image) }
            }
        }
        .navigationTitle("Import Past Orders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
