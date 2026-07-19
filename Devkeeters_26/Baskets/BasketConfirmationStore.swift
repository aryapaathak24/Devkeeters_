//
//  BasketConfirmationStore.swift
//  Devkeeters_26
//
//  Tracks confirm/skip history so repeated skips can back off rather than
//  keep nudging at the same cadence — the "user skips several weeks in a
//  row" edge case from 03_predictive_baskets.json. No real push backend
//  here, just the state a future notification scheduler would read.
//

import Foundation

struct BasketConfirmationState: Codable {
    var lastConfirmedDate: Date?
    var consecutiveSkips: Int = 0
}

final class BasketConfirmationStore {
    static let shared = BasketConfirmationStore()
    private init() {}

    private let key = "com.devkeeters.basketConfirmation"

    func load() -> BasketConfirmationState {
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(BasketConfirmationState.self, from: data) else {
            return BasketConfirmationState()
        }
        return state
    }

    func save(_ state: BasketConfirmationState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func recordConfirmed() {
        var state = load()
        state.lastConfirmedDate = Date()
        state.consecutiveSkips = 0
        save(state)
    }

    func recordSkipped() {
        var state = load()
        state.consecutiveSkips += 1
        save(state)
    }

    func shouldBackOffNotifications() -> Bool {
        load().consecutiveSkips >= 2
    }
}
