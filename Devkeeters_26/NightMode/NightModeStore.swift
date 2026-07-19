//
//  NightModeStore.swift
//  Devkeeters_26
//
//  Persists whether the auto-suggested Night Mode banner was already
//  dismissed today, so it doesn't nag on every app open. Same
//  UserDefaults + Codable idiom as Models/LastOrderStore.swift.
//

import Foundation

struct NightModeState: Codable {
    var lastBannerDismissedOn: Date?
}

final class NightModeStore {
    static let shared = NightModeStore()
    private init() {}

    private let key = "com.devkeeters.nightMode.state"

    func save(_ state: NightModeState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func load() -> NightModeState {
        guard let data = UserDefaults.standard.data(forKey: key),
              let state = try? JSONDecoder().decode(NightModeState.self, from: data) else {
            return NightModeState()
        }
        return state
    }

    func dismissBannerForToday() {
        save(NightModeState(lastBannerDismissedOn: Date()))
    }

    func wasBannerDismissedToday(now: Date = Date()) -> Bool {
        guard let dismissedOn = load().lastBannerDismissedOn else { return false }
        return Calendar.current.isDate(dismissedOn, inSameDayAs: now)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
