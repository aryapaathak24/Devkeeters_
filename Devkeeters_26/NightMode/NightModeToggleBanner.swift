//
//  NightModeToggleBanner.swift
//  Devkeeters_26
//
//  mode_toggle screen from 06_night_emergency_mode.json — lives inline on
//  the Home tab (ContentView), either as a subtle always-present entry
//  point or a prominent auto-suggested variant after ~10pm.
//

import SwiftUI

struct NightModeToggleBanner: View {
    var isAutoSuggested: Bool
    var onEnable: () -> Void
    var onDismiss: (() -> Void)?

    var body: some View {
        Button(action: onEnable) {
            HStack(spacing: 14) {
                IconBadge(systemImage: "moon.stars.fill")

                VStack(alignment: .leading, spacing: 3) {
                    Text(isAutoSuggested ? "Late night? Switch to Night Mode" : "Night Emergency Mode")
                        .font(.theme.bodyMd.weight(.semibold))
                        .foregroundStyle(Color.theme.onSurface)
                    Text(isAutoSuggested
                         ? "Only shows what's open right now, nearby"
                         : "Pharmacies, baby care & essentials open now")
                        .font(.theme.labelSm)
                        .foregroundStyle(Color.theme.onSurfaceVariant)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isAutoSuggested, let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.theme.outline)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.theme.outline)
                }
            }
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}
