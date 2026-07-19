//
//  ItemDetailView.swift
//  Devkeeters_26
//
//  item_detail screen — quantity editor, predicted run-out date,
//  mark_out/delete actions.
//

import SwiftUI

struct ItemDetailView: View {
    let item: PantryItem
    let viewModel: PantryViewModel

    @State private var quantity: Int
    @Environment(\.dismiss) private var dismiss

    init(item: PantryItem, viewModel: PantryViewModel) {
        self.item = item
        self.viewModel = viewModel
        _quantity = State(initialValue: item.estimatedQuantity)
    }

    var body: some View {
        Form {
            Section("Quantity") {
                Stepper("\(quantity) \(item.unit)", value: $quantity, in: 0...50)
            }

            Section {
                Text("Likely out around \(item.predictedRunOutDate.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Mark as Out", role: .destructive) {
                    viewModel.markOut(item)
                    dismiss()
                }
                Button("Delete Item", role: .destructive) {
                    viewModel.deleteItem(item)
                    dismiss()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.theme.background)
        .tint(Color.theme.primary)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.editQuantity(item, quantity: quantity)
                    dismiss()
                }
            }
        }
    }
}
