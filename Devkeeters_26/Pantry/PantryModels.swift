//
//  PantryModels.swift
//  Devkeeters_26
//
//  Models for PantryLens — see 01_pantrylens.json. Receipt-only scope:
//  no fridge-photo scan_capture (deferred by the JSON's own notes).
//

import Foundation

enum PantryCategory: String, CaseIterable, Codable, Hashable {
    case dairy, produce, bakery, staple, other

    var displayName: String { rawValue.capitalized }

    /// Default days-until-likely-out, used when there's no purchase
    /// history to derive a real interval from.
    var defaultRunOutWindowDays: Int {
        switch self {
        case .dairy: 7
        case .produce: 5
        case .bakery: 4
        case .staple: 21
        case .other: 14
        }
    }
}

struct PantryItem: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: PantryCategory
    var estimatedQuantity: Int
    var unit: String
    var lastSeenDate: Date

    init(id: UUID = UUID(), name: String, category: PantryCategory = .other, estimatedQuantity: Int = 1, unit: String = "pc", lastSeenDate: Date = Date()) {
        self.id = id
        self.name = name
        self.category = category
        self.estimatedQuantity = estimatedQuantity
        self.unit = unit
        self.lastSeenDate = lastSeenDate
    }

    var predictedRunOutDate: Date {
        Calendar.current.date(byAdding: .day, value: category.defaultRunOutWindowDays, to: lastSeenDate) ?? lastSeenDate
    }
}
