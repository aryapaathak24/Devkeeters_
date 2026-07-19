//
//  VendorDetailNightView.swift
//  Devkeeters_26
//
//  vendor_detail_night screen — stripped-down product list, local cart,
//  streamlined checkout. No OrderingCoordinator involvement (see build
//  plan §3): this is a standalone mock confirmation, not a live-tracked
//  Zomato order.
//

import SwiftUI

struct VendorDetailNightView: View {
    let vendor: NightVendor
    let viewModel: NightModeViewModel

    @State private var cart: Set<UUID> = []
    @State private var showConfirmation = false

    private var products: [NightProduct] { viewModel.products(for: vendor) }
    private var cartItems: [NightProduct] { products.filter { cart.contains($0.id) } }
    private var total: Int { cartItems.map(\.price).reduce(0, +) }

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    HStack {
                        Label(vendor.openUntilText, systemImage: "clock.fill")
                        Spacer()
                        Label("\(vendor.etaMinutes) min ETA", systemImage: "bolt.fill")
                    }
                    .font(.theme.labelSm)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
                }

                Section("Available now") {
                    ForEach(products) { product in
                        productRow(product)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)

            if !cart.isEmpty {
                checkoutBar
            }
        }
        .background(Color.theme.background)
        .navigationTitle(vendor.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showConfirmation) {
            NightOrderConfirmedView(vendor: vendor, items: cartItems, total: total)
        }
    }

    private func productRow(_ product: NightProduct) -> some View {
        let isSelected = cart.contains(product.id)
        return Button {
            if isSelected { cart.remove(product.id) } else { cart.insert(product.id) }
        } label: {
            HStack {
                Text(product.emoji)
                Text(product.name)
                Spacer()
                Text("₹\(product.price)").foregroundStyle(Color.theme.onSurfaceVariant)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.theme.primary : Color.theme.outline)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.theme.onSurface)
    }

    private var checkoutBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text("\(cart.count) item\(cart.count == 1 ? "" : "s") · ₹\(total)")
                    .font(.theme.bodyMd.weight(.semibold))
                    .foregroundStyle(Color.theme.onSurface)
                Spacer()
                Button("Checkout") { showConfirmation = true }
                    .buttonStyle(.themePrimary)
                    .fixedSize()
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
}
