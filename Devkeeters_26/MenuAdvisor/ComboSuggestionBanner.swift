//
//  ComboSuggestionBanner.swift
//  Devkeeters_26
//
//  combo_suggestion_banner screen — inline nudge on VendorMenuView.
//

import SwiftUI

struct ComboSuggestionBanner: View {
    let combo: ComboDeal
    let savings: Int
    var onApply: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.title3)
                .foregroundStyle(Color.theme.success)

            VStack(alignment: .leading, spacing: 2) {
                Text("Switch to \(combo.name) and save ₹\(savings)")
                    .font(.theme.bodyMd.weight(.semibold))
                    .foregroundStyle(Color.theme.onSurface)
                Text("Same items, better price")
                    .font(.theme.labelSm)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }

            Spacer()

            Button("Apply", action: onApply)
                .buttonStyle(.themeSecondary)
                .controlSize(.small)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: ThemeMetrics.radiusMD).fill(Color.theme.success.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: ThemeMetrics.radiusMD).stroke(Color.theme.success.opacity(0.3), lineWidth: 1))
    }
}
