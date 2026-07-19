//
//  VendorMenuView.swift
//  Devkeeters_26
//
//  vendor_menu screen — item grid with the combo banner injected inline
//  when relevant.
//

import SwiftUI

struct VendorMenuView: View {
    let vendor: AdvisorVendor
    let viewModel: MenuAdvisorViewModel

    @State private var showCartSummary = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if let combo = viewModel.suggestedCombo {
                    ComboSuggestionBanner(
                        combo: combo,
                        savings: combo.savings(in: vendor.items),
                        onApply: { viewModel.applyCombo(combo) },
                        onDismiss: { viewModel.dismissSuggestedCombo() }
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vendor.items) { item in
                        itemCard(item)
                    }
                }
                .padding()
            }

            if !viewModel.cart.isEmpty {
                cartBar
            }
        }
        .background(Color.theme.background)
        .navigationTitle(vendor.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.selectedVendor = vendor }
        .navigationDestination(isPresented: $showCartSummary) {
            CartValueSummaryView(viewModel: viewModel)
        }
    }

    private func itemCard(_ item: AdvisorMenuItem) -> some View {
        let inCart = viewModel.cart.contains(item)
        return Button {
            if inCart { viewModel.removeFromCart(item) } else { viewModel.addToCart(item) }
        } label: {
            VStack(spacing: 6) {
                Text(item.emoji).font(.system(size: 36))
                Text(item.name)
                    .font(.theme.bodyMd.weight(.semibold))
                    .foregroundStyle(Color.theme.onSurface)
                    .multilineTextAlignment(.center)
                Text("₹\(item.price)").font(.theme.labelSm).foregroundStyle(Color.theme.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: ThemeMetrics.radiusMD)
                    .fill(inCart ? Color.theme.accentWarm : Color.theme.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeMetrics.radiusMD)
                    .stroke(inCart ? Color.theme.onSurface : Color.theme.outlineVariant, lineWidth: inCart ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.theme.onSurface)
    }

    private var cartBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.cart.count) item\(viewModel.cart.count == 1 ? "" : "s") · ₹\(viewModel.cartTotal)")
                        .font(.theme.bodyMd.weight(.semibold))
                        .foregroundStyle(Color.theme.onSurface)
                    if viewModel.totalSavings > 0 {
                        Text("You're saving ₹\(viewModel.totalSavings)")
                            .font(.theme.labelSm)
                            .foregroundStyle(Color.theme.success)
                    }
                }
                Spacer()
                Button("View Cart") { showCartSummary = true }
                    .buttonStyle(.themePrimary)
                    .fixedSize()
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
}
