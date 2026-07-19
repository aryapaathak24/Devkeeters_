//
//  OrderViewModel.swift
//  Devkeeters_26
//
//  Touch-fallback entry point. Wraps OrderingCoordinator so ContentView
//  never talks to the brain or ZomatoService directly (strict MVVM).
//  Calls the exact same OrderingCoordinator.placeOrder(from:) Siri uses.
//  Now also exposes reorderUsual() for the "Order Again" touch fallback.
//

import Foundation
import Observation

@MainActor
@Observable
final class OrderViewModel {
    var orderText: String = ""
    private(set) var isSubmitting = false
    private(set) var lastErrorMessage: String?

    // Last order — shown in the "My Usual" card
    private(set) var savedOrder: SavedOrder? = LastOrderStore.shared.load()

    private let coordinator: OrderingCoordinator

    @MainActor
    init(coordinator: OrderingCoordinator = .shared) {
        self.coordinator = coordinator
    }

    var coordinatorState: OrderingCoordinator.State { coordinator.state }

    // MARK: - New text order

    func submit() async {
        let text = orderText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSubmitting else { return }

        isSubmitting = true
        lastErrorMessage = nil
        defer { isSubmitting = false }

        do {
            _ = try await coordinator.placeOrder(from: text)
            orderText = ""
            savedOrder = LastOrderStore.shared.load()  // refresh the usual card
        } catch let error as OrderingCoordinatorError {
            lastErrorMessage = error.errorDescription
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Reorder usual (touch fallback for "Order My Usual")

    func reorderUsual() async {
        guard let last = LastOrderStore.shared.load(), !isSubmitting else { return }

        isSubmitting = true
        lastErrorMessage = nil
        defer { isSubmitting = false }

        let service = ZomatoService()
        let availability = service.checkAvailability(for: last.items)
        let available = last.items.filter { availability[$0] == true }

        guard !available.isEmpty else {
            lastErrorMessage = "None of your usual items are available right now."
            return
        }

        let summary = service.buildOrderSummary(from: available, restaurant: last.restaurantName)
        do {
            _ = try coordinator.placeOrder(summary: summary)
            savedOrder = LastOrderStore.shared.load()
        } catch let error as OrderingCoordinatorError {
            lastErrorMessage = error.errorDescription
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Save a manually picked usual (from ManageUsualView)

    func saveCustomUsual(from order: SavedOrder) {
        LastOrderStore.shared.save(
            OrderSummary(
                domain: .zomato,
                title: order.items.joined(separator: ", "),
                items: order.items,
                restaurantName: order.restaurantName,
                totalPrice: order.totalPrice,
                initialStatus: "Order placed",
                etaMinutes: order.etaMinutes
            )
        )
        savedOrder = LastOrderStore.shared.load()
    }
}
