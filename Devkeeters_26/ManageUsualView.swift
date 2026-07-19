//
//  ManageUsualView.swift
//  Devkeeters_26
//
//  Visual sheet for picking and saving "My Usual" order.
//  No typing — tap food cards to select/deselect, see live price,
//  pick a restaurant, then save. Opens from the usual card's Edit button.
//

import SwiftUI

// MARK: - Menu Item Model

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let price: Int
    let etaMinutes: Int
}

// MARK: - Full Demo Menu

extension MenuItem {
    static let all: [MenuItem] = [
        MenuItem(name: "Butter Chicken",  emoji: "🍗", price: 280, etaMinutes: 28),
        MenuItem(name: "Naan",            emoji: "🫓", price: 60,  etaMinutes: 10),
        MenuItem(name: "Garlic Naan",     emoji: "🧄", price: 70,  etaMinutes: 12),
        MenuItem(name: "Biryani",         emoji: "🍚", price: 320, etaMinutes: 35),
        MenuItem(name: "Paneer Tikka",    emoji: "🧀", price: 220, etaMinutes: 22),
        MenuItem(name: "Dal Makhani",     emoji: "🫘", price: 190, etaMinutes: 25),
        MenuItem(name: "Pizza",           emoji: "🍕", price: 350, etaMinutes: 25),
        MenuItem(name: "Burger",          emoji: "🍔", price: 180, etaMinutes: 18),
        MenuItem(name: "Pasta",           emoji: "🍝", price: 240, etaMinutes: 20),
        MenuItem(name: "Dosa",            emoji: "🥞", price: 90,  etaMinutes: 15),
        MenuItem(name: "Noodles",         emoji: "🍜", price: 160, etaMinutes: 18),
        MenuItem(name: "Fried Rice",      emoji: "🍳", price: 140, etaMinutes: 18),
        MenuItem(name: "Sushi",           emoji: "🍣", price: 480, etaMinutes: 30),
        MenuItem(name: "Salad",           emoji: "🥗", price: 120, etaMinutes: 12),
        MenuItem(name: "Sandwich",        emoji: "🥪", price: 110, etaMinutes: 10),
        MenuItem(name: "Masala Chai",     emoji: "🫖", price: 40,  etaMinutes: 5),
    ]

    static let restaurants = [
        "Spice Garden", "The Curry House", "Biryani Bros",
        "Delhi Darbar", "Urban Tadka"
    ]
}

// MARK: - View

struct ManageUsualView: View {

    // Passed in from parent
    let current: SavedOrder?
    let onSave: (SavedOrder) -> Void

    @Environment(\.dismiss) private var dismiss

    // Local state
    @State private var selected: Set<String> = []
    @State private var chosenRestaurant: String = MenuItem.restaurants[0]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    // MARK: Computed

    private var selectedItems: [MenuItem] {
        MenuItem.all.filter { selected.contains($0.name) }
    }

    private var totalPrice: Int { selectedItems.map(\.price).reduce(0, +) }

    private var maxETA: Int {
        (selectedItems.map(\.etaMinutes).max() ?? 0) + 12   // +12 min delivery
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Restaurant picker ──────────────────────────────
                    restaurantPicker

                    // ── Menu grid ─────────────────────────────────────
                    Text("Pick your items")
                        .font(.theme.headlineMd)
                        .foregroundStyle(Color.theme.onSurface)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(MenuItem.all) { item in
                            menuCard(item)
                        }
                    }
                    .padding(.horizontal)

                    // ── Bottom spacer so FAB doesn't cover last row ───
                    Color.clear.frame(height: 100)
                }
                .padding(.top)
            }
            .background(Color.theme.background)
            .navigationTitle("My Usual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveBar
            }
        }
        .onAppear { loadCurrent() }
    }

    // MARK: - Restaurant Picker

    private var restaurantPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Restaurant")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MenuItem.restaurants, id: \.self) { r in
                        Button {
                            chosenRestaurant = r
                        } label: {
                            Text(r)
                                .font(.theme.bodyMd.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(chosenRestaurant == r
                                            ? Color.theme.primary
                                            : Color.theme.surfaceContainer)
                                )
                                .foregroundStyle(chosenRestaurant == r ? Color.theme.onPrimary : Color.theme.onSurface)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Menu Card

    private func menuCard(_ item: MenuItem) -> some View {
        let isSelected = selected.contains(item.name)

        return Button {
            if isSelected { selected.remove(item.name) }
            else          { selected.insert(item.name) }
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Text(item.emoji)
                        .font(.system(size: 44))

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.theme.onPrimary, Color.theme.primary)
                            .font(.title3)
                            .offset(x: 6, y: -6)
                    }
                }

                Text(item.name)
                    .font(.theme.bodyMd.weight(.semibold))
                    .foregroundStyle(Color.theme.onSurface)
                    .multilineTextAlignment(.center)

                Text("₹\(item.price)")
                    .font(.theme.labelSm)
                    .foregroundStyle(Color.theme.onSurfaceVariant)

                Label("\(item.etaMinutes) min", systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: ThemeMetrics.radiusMD)
                    .fill(isSelected ? Color.theme.accentWarm : Color.theme.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeMetrics.radiusMD)
                    .stroke(isSelected ? Color.theme.onSurface : Color.theme.outlineVariant, lineWidth: isSelected ? 1.5 : 1)
            )
            .animation(.spring(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save Bar (pinned to bottom)

    @ViewBuilder
    private var saveBar: some View {
        if !selected.isEmpty {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selected.count) item\(selected.count == 1 ? "" : "s") · ₹\(totalPrice)")
                        .font(.theme.bodyMd.weight(.semibold))
                        .foregroundStyle(Color.theme.onSurface)
                    Text("~\(maxETA) min ETA")
                        .font(.theme.labelSm)
                        .foregroundStyle(Color.theme.onSurfaceVariant)
                }

                Spacer()

                Button("Save as Usual") {
                    let order = SavedOrder(
                        items: selectedItems.map(\.name),
                        restaurantName: chosenRestaurant,
                        totalPrice: totalPrice,
                        etaMinutes: maxETA
                    )
                    onSave(order)
                    dismiss()
                }
                .buttonStyle(.themePrimary)
                .fixedSize()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(Divider(), alignment: .top)
        }
    }

    // MARK: - Load current usual into selection state

    private func loadCurrent() {
        guard let current else { return }
        // Pre-select items that match the saved usual
        for item in MenuItem.all where current.items.contains(where: {
            $0.lowercased() == item.name.lowercased()
        }) {
            selected.insert(item.name)
        }
        if MenuItem.restaurants.contains(current.restaurantName) {
            chosenRestaurant = current.restaurantName
        }
    }
}

#Preview {
    ManageUsualView(current: nil) { _ in }
}
