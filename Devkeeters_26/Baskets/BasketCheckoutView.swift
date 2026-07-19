//
//  BasketCheckoutView.swift
//  Devkeeters_26
//
//  Terminal checkout screen for the predicted basket flow. No
//  OrderingCoordinator involvement (see build plan §3) — this is a
//  standalone mock confirmation, not a live-tracked Zomato order.
//

import SwiftUI

struct BasketCheckoutView: View {
    let items: [PredictedItem]
    let total: Int

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.theme.success)

            Text("Basket Confirmed")
                .font(.theme.headlineLg)
                .foregroundStyle(Color.theme.onSurface)

            Text("Your weekly order is on its way to checkout.")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)

            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("₹\(item.estimatedPrice)")
                    }
                }
                HStack {
                    Text("Total").font(.theme.headlineMd)
                    Spacer()
                    Text("₹\(total)").font(.theme.headlineMd)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)
        }
        .padding(.top)
        .background(Color.theme.background)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
