//
//  PredictedBasketHomeView.swift
//  Devkeeters_26
//
//  predicted_basket_home screen — Baskets tab root. There's no real
//  scheduled backend job here (see build plan), so unlike the JSON's
//  "prediction job failed silently" error state, there's no failure path
//  to model — refresh() is a pure local computation. Cold-start/starter
//  and success states are both real and reachable (see
//  PredictedBasketViewModel.refresh()).
//

import SwiftUI

struct PredictedBasketHomeView: View {
    @State private var viewModel = PredictedBasketViewModel()
    @State private var showCheckout = false
    @State private var showImport = false

    var body: some View {
        List {
            if viewModel.isColdStart {
                Section {
                    Text("Starter basket — we'll learn your pattern after a few orders.")
                        .font(.theme.labelSm)
                        .foregroundStyle(Color.theme.onSurfaceVariant)
                }
            }

            Section {
                ForEach(viewModel.predictedItems) { item in
                    NavigationLink(value: item) {
                        basketRow(item)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { viewModel.removeItem(viewModel.predictedItems[index]) }
                }
            } header: {
                Text("This week's basket")
            } footer: {
                HStack {
                    Text("Total")
                    Spacer()
                    Text("₹\(viewModel.runningTotal)")
                }
                .font(.subheadline.weight(.semibold))
            }

            Section {
                Button {
                    showImport = true
                } label: {
                    Label("Import past orders (Smart Reading)", systemImage: "doc.text.viewfinder")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.theme.background)
        .tint(Color.theme.primary)
        .navigationTitle("Predicted Basket")
        .navigationDestination(for: PredictedItem.self) { item in
            ConfidenceDetailView(item: item) { viewModel.removeItem(item) }
        }
        .navigationDestination(isPresented: $showCheckout) {
            BasketCheckoutView(items: viewModel.predictedItems, total: viewModel.runningTotal)
        }
        .sheet(isPresented: $showImport) {
            NavigationStack { OrderHistoryImportView() }
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .onAppear { viewModel.refresh() }
    }

    private func basketRow(_ item: PredictedItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.theme.bodyMd.weight(.semibold)).foregroundStyle(Color.theme.onSurface)
                confidenceChip(item.confidence)
            }
            Spacer()
            Text("₹\(item.estimatedPrice)").foregroundStyle(Color.theme.onSurfaceVariant)
        }
    }

    private func confidenceChip(_ confidence: PredictionConfidence) -> some View {
        let label: String
        let color: Color
        switch confidence {
        case .high: label = "High confidence"; color = .theme.success
        case .medium: label = "Medium confidence"; color = .theme.warning
        case .starter: label = "Starter pick"; color = .theme.onSurfaceVariant
        }
        return PillChip(text: label, tint: color, background: color.opacity(0.15))
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Button("Skip this week") { viewModel.skipThisWeek() }
                    .buttonStyle(.themeGhost)
                Button("Confirm Basket") {
                    viewModel.confirmBasket()
                    showCheckout = true
                }
                .buttonStyle(.themePrimary)
            }
            .padding()
        }
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack { PredictedBasketHomeView() }
}
