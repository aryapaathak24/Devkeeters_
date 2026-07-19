//
//  MenuAdvisorViewModel.swift
//  Devkeeters_26
//
//  Bridges MenuAdvisorService to the vendor/menu/cart views. Checkout is
//  genuine .zomato-domain food ordering, so it reuses
//  OrderingCoordinator.placeOrder(summary:) unmodified — the only one of
//  the four new features that goes through the coordinator (see build
//  plan §3). That also means a successful checkout here shows up as live
//  tracking on the Home tab, for free.
//

import Foundation

@MainActor
@Observable
final class MenuAdvisorViewModel {
    private let service: any MenuAdvisorProviding
    private let coordinator: OrderingCoordinator

    private(set) var vendors: [AdvisorVendor] = []
    var selectedVendor: AdvisorVendor?
    private(set) var cart: [AdvisorMenuItem] = []
    private(set) var appliedCombo: ComboDeal?
    private(set) var dismissedComboID: UUID?
    private(set) var lastErrorMessage: String?

    init(service: any MenuAdvisorProviding = MenuAdvisorService(), coordinator: OrderingCoordinator = .shared) {
        self.service = service
        self.coordinator = coordinator
        self.vendors = service.vendors()
    }

    var coordinatorState: OrderingCoordinator.State { coordinator.state }

    /// Only shown when unseen for the current cart and not already applied
    /// — matches the "dismiss" primary action from combo_suggestion_banner.
    var suggestedCombo: ComboDeal? {
        guard appliedCombo == nil, let selectedVendor else { return nil }
        let combo = service.bestCombo(forCart: cart, at: selectedVendor)
        return combo?.id == dismissedComboID ? nil : combo
    }

    var totalSavings: Int {
        guard let appliedCombo, let selectedVendor else { return 0 }
        return appliedCombo.savings(in: selectedVendor.items)
    }

    var cartTotal: Int {
        guard let appliedCombo else {
            return cart.map(\.price).reduce(0, +)
        }
        let nonComboItems = cart.filter { !appliedCombo.includedItemNames.contains($0.name) }
        return appliedCombo.comboPrice + nonComboItems.map(\.price).reduce(0, +)
    }

    func addToCart(_ item: AdvisorMenuItem) {
        cart.append(item)
    }

    func removeFromCart(_ item: AdvisorMenuItem) {
        if let index = cart.firstIndex(of: item) { cart.remove(at: index) }
    }

    func applyCombo(_ combo: ComboDeal) {
        appliedCombo = combo
    }

    func dismissSuggestedCombo() {
        dismissedComboID = suggestedCombo?.id
    }

    func checkout() {
        guard let selectedVendor, !cart.isEmpty else { return }
        let itemNames = cart.map(\.name)
        let summary = OrderSummary(
            domain: .zomato,
            title: itemNames.joined(separator: ", "),
            items: itemNames,
            restaurantName: selectedVendor.name,
            totalPrice: cartTotal,
            initialStatus: "Order placed",
            etaMinutes: 30
        )
        do {
            _ = try coordinator.placeOrder(summary: summary)
            cart = []
            appliedCombo = nil
            dismissedComboID = nil
            lastErrorMessage = nil
        } catch let error as OrderingCoordinatorError {
            lastErrorMessage = error.errorDescription
        } catch {
            lastErrorMessage = "Something went wrong placing that order."
        }
    }
}
