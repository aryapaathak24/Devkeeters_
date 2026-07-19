//
//  PantryHomeView.swift
//  Devkeeters_26
//
//  pantry_home screen — Pantry tab root. The "scan_pantry" (fridge photo)
//  action is intentionally omitted here — that flow is deferred per
//  01_pantrylens.json's own notes; only scan_receipt and
//  add_item_manually are wired.
//

import SwiftUI

struct PantryHomeView: View {
    @State private var viewModel = PantryViewModel()
    @State private var showReceiptImport = false
    @State private var showAddManually = false

    var body: some View {
        Group {
            if viewModel.isEmpty {
                emptyState
            } else {
                List {
                    if !viewModel.lowStockItems.isEmpty {
                        Section("Low stock") {
                            ForEach(viewModel.lowStockItems) { item in
                                NavigationLink(value: item) { itemRow(item, isLow: true) }
                            }
                        }
                    }
                    if !viewModel.wellStockedItems.isEmpty {
                        Section("Well stocked") {
                            ForEach(viewModel.wellStockedItems) { item in
                                NavigationLink(value: item) { itemRow(item, isLow: false) }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.theme.background)
            }
        }
        .background(Color.theme.background)
        .tint(Color.theme.primary)
        .navigationTitle("Pantry")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showReceiptImport = true } label: {
                        Label("Scan Receipt", systemImage: "camera.fill")
                    }
                    Button { showAddManually = true } label: {
                        Label("Add Manually", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .navigationDestination(for: PantryItem.self) { item in
            ItemDetailView(item: item, viewModel: viewModel)
        }
        .sheet(isPresented: $showReceiptImport) {
            NavigationStack { ReceiptImportView(viewModel: viewModel) }
        }
        .sheet(isPresented: $showAddManually) {
            AddItemManuallyView { name, category, quantity, unit in
                viewModel.addManualItem(name: name, category: category, quantity: quantity, unit: unit)
            }
        }
        .onAppear { viewModel.refresh() }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cabinet")
                .font(.system(size: 48))
                .foregroundStyle(Color.theme.outline)
            Text("Nothing scanned yet")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)
            Text("Scan a receipt after your next grocery run and we'll track what's running low.")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Scan Receipt") { showReceiptImport = true }
                .buttonStyle(.themePrimary)
                .fixedSize()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }

    private func itemRow(_ item: PantryItem, isLow: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.theme.bodyMd.weight(.semibold)).foregroundStyle(Color.theme.onSurface)
                Text("Last seen \(item.lastSeenDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.theme.labelSm)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.estimatedQuantity) \(item.unit)")
                    .font(.theme.labelSm)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
                if isLow {
                    Text("Likely out \(item.predictedRunOutDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.theme.warning)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { PantryHomeView() }
}
