//
//  NightOrderConfirmedView.swift
//  Devkeeters_26
//
//  Terminal order_confirmed screen for the Night Mode checkout flow.
//

import SwiftUI

struct NightOrderConfirmedView: View {
    let vendor: NightVendor
    let items: [NightProduct]
    let total: Int

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.theme.success)

            Text("Order Confirmed")
                .font(.theme.headlineLg)
                .foregroundStyle(Color.theme.onSurface)

            Text("\(vendor.name) is preparing your order — \(vendor.etaMinutes) min ETA")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items) { item in
                    HStack {
                        Text("\(item.emoji) \(item.name)")
                        Spacer()
                        Text("₹\(item.price)")
                    }
                    .font(.theme.bodyMd)
                    .foregroundStyle(Color.theme.onSurface)
                }
                Divider().overlay(Color.theme.outlineVariant)
                HStack {
                    Text("Total").font(.theme.bodyMd.weight(.semibold))
                    Spacer()
                    Text("₹\(total)").font(.theme.bodyMd.weight(.semibold))
                }
                .foregroundStyle(Color.theme.onSurface)
            }
            .glassCard()

            Spacer()
        }
        .padding()
        .background(Color.theme.background)
        .navigationTitle("Confirmed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
