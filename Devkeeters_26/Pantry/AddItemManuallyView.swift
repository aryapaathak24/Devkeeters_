//
//  AddItemManuallyView.swift
//  Devkeeters_26
//
//  Keeps manual entry a first-class path from every degraded scan state,
//  per 01_pantrylens.json's edge cases.
//

import SwiftUI

struct AddItemManuallyView: View {
    var onSave: (String, PantryCategory, Int, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: PantryCategory = .other
    @State private var quantity = 1
    @State private var unit = "pc"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                Picker("Category", selection: $category) {
                    ForEach(PantryCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                Stepper("Quantity: \(quantity)", value: $quantity, in: 0...50)
                TextField("Unit (e.g. pc, kg, L)", text: $unit)
            }
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)
            .tint(Color.theme.primary)
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, category, quantity, unit)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
