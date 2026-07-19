//
//  ScanReviewView.swift
//  Devkeeters_26
//
//  scan_review screen — built generic over [ReceiptLineItem] (not tied to
//  pantry-only fields) so it's reusable later for the deferred fridge
//  scan_capture flow without extra work, per the JSON's own note.
//

import SwiftUI

struct ScanReviewView: View {
    var onConfirm: ([ReceiptLineItem]) -> Void

    @State private var editableItems: [ReceiptLineItem]

    init(items: [ReceiptLineItem], onConfirm: @escaping ([ReceiptLineItem]) -> Void) {
        self.onConfirm = onConfirm
        _editableItems = State(initialValue: items)
    }

    var body: some View {
        Group {
            if editableItems.isEmpty {
                emptyState
            } else {
                List {
                    ForEach($editableItems) { $item in
                        row(for: $item)
                    }
                    .onDelete { editableItems.remove(atOffsets: $0) }
                }
                .scrollContentBackground(.hidden)
                .background(Color.theme.background)
            }
        }
        .background(Color.theme.background)
        .tint(Color.theme.primary)
        .navigationTitle("Review Scan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") { onConfirm(editableItems) }
                    .disabled(editableItems.isEmpty)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.text.page")
                .font(.system(size: 40))
                .foregroundStyle(Color.theme.outline)
            Text("Couldn't detect anything clearly")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)
            Text("Add items manually instead.")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }

    private func row(for item: Binding<ReceiptLineItem>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                TextField("Name", text: item.name)
                    .font(.subheadline.weight(.semibold))
                confidenceLabel(item.wrappedValue.confidence)
            }
            Spacer()
            Stepper(value: item.quantity, in: 0...50) {
                Text("\(item.wrappedValue.quantity)")
            }
            .frame(width: 100)
        }
    }

    private func confidenceLabel(_ confidence: OCRConfidence) -> some View {
        let text: String
        let color: Color
        switch confidence {
        case .high: text = "High confidence"; color = .theme.success
        case .medium: text = "Medium confidence"; color = .theme.warning
        case .low: text = "Low confidence — check this"; color = .theme.errorColor
        }
        return Text(text).font(.theme.labelSm).foregroundStyle(color)
    }
}
