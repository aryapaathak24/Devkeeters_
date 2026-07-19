//
//  ConfidenceDetailView.swift
//  Devkeeters_26
//
//  confidence_detail screen — plain-language explanation, no algorithm
//  jargon, per 03_predictive_baskets.json.
//

import SwiftUI

struct ConfidenceDetailView: View {
    let item: PredictedItem
    var onRemove: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.name).font(.theme.headlineLg).foregroundStyle(Color.theme.onSurface)

            explanation
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)

            Spacer()

            Button(role: .destructive) {
                onRemove()
                dismiss()
            } label: {
                Label("Remove from basket", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(Color.theme.errorColor)
        }
        .padding()
        .background(Color.theme.background)
        .navigationTitle("Why This Item?")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var explanation: some View {
        switch item.confidence {
        case .high, .medium:
            if let avgIntervalDays = item.avgIntervalDays, let lastPurchased = item.lastPurchased {
                Text("You've bought this every ~\(Int(avgIntervalDays.rounded())) days, last on \(lastPurchased.formatted(date: .abbreviated, time: .omitted)).")
            }
        case .starter:
            Text("We don't have enough order history for this item yet — it's a common starter pick while we learn your pattern.")
        }
    }
}
