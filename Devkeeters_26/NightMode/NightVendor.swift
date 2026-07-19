//
//  NightVendor.swift
//  Devkeeters_26
//
//  Models for Night Emergency Mode — see 06_night_emergency_mode.json.
//

import Foundation

enum NightCategory: String, CaseIterable, Identifiable, Hashable {
    case pharmacy, babyCare, essentials, groceryNight

    var id: Self { self }

    var displayName: String {
        switch self {
        case .pharmacy: "Pharmacy"
        case .babyCare: "Baby"
        case .essentials: "Essentials"
        case .groceryNight: "Grocery"
        }
    }

    var systemImage: String {
        switch self {
        case .pharmacy: "cross.case.fill"
        case .babyCare: "figure.and.child.holdinghands"
        case .essentials: "bag.fill"
        case .groceryNight: "carrot.fill"
        }
    }
}

struct NightVendor: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var category: NightCategory
    var distanceKm: Double
    var etaMinutes: Int
    var is24Hour: Bool
    /// Ignored when `is24Hour` is true. A value <= 5 means "closes in the
    /// early morning" (the open window spans midnight).
    var closesAtHour: Int

    var openUntilText: String {
        is24Hour ? "Open 24 hours" : "Open until \(Self.formatted(hour: closesAtHour))"
    }

    func isOpenNow(at date: Date = Date()) -> Bool {
        if is24Hour { return true }
        let hour = Calendar.current.component(.hour, from: date)
        if closesAtHour <= 5 {
            return hour >= 20 || hour < closesAtHour
        }
        return hour < closesAtHour
    }

    private static func formatted(hour: Int) -> String {
        let suffix = hour < 12 ? "AM" : "PM"
        let display = hour % 12 == 0 ? 12 : hour % 12
        return "\(display) \(suffix)"
    }
}

struct NightProduct: Identifiable {
    let id = UUID()
    var name: String
    var emoji: String
    var price: Int
}
