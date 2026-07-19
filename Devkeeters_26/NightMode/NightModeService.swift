//
//  NightModeService.swift
//  Devkeeters_26
//
//  Mock vendor catalog for Night Emergency Mode. In-memory only, no
//  CoreLocation — distances are seeded static values, consistent with the
//  rest of the app's mock-data approach.
//

import Foundation

protocol NightVendorProviding {
    func vendors(withinKm radius: Double, category: NightCategory?, at date: Date) -> [NightVendor]
    func products(for vendor: NightVendor) -> [NightProduct]
}

struct NightModeService: NightVendorProviding {

    private static let allVendors: [NightVendor] = [
        NightVendor(name: "Apollo 24/7 Pharmacy", category: .pharmacy, distanceKm: 1.2, etaMinutes: 15, is24Hour: true, closesAtHour: 0),
        NightVendor(name: "MedPlus Night Counter", category: .pharmacy, distanceKm: 2.8, etaMinutes: 22, is24Hour: false, closesAtHour: 2),
        NightVendor(name: "CityCare Pharmacy", category: .pharmacy, distanceKm: 6.4, etaMinutes: 35, is24Hour: false, closesAtHour: 21),
        NightVendor(name: "LittleOnes Baby Store", category: .babyCare, distanceKm: 3.5, etaMinutes: 25, is24Hour: false, closesAtHour: 1),
        NightVendor(name: "Cradle & Co.", category: .babyCare, distanceKm: 9.1, etaMinutes: 40, is24Hour: false, closesAtHour: 20),
        NightVendor(name: "QuickMart 24x7", category: .essentials, distanceKm: 0.8, etaMinutes: 12, is24Hour: true, closesAtHour: 0),
        NightVendor(name: "Night Owl Essentials", category: .essentials, distanceKm: 4.2, etaMinutes: 28, is24Hour: false, closesAtHour: 3),
        NightVendor(name: "FreshBasket Late Grocery", category: .groceryNight, distanceKm: 5.0, etaMinutes: 30, is24Hour: false, closesAtHour: 23)
    ]

    private static let productCatalog: [NightCategory: [NightProduct]] = [
        .pharmacy: [
            NightProduct(name: "Paracetamol 500mg", emoji: "💊", price: 30),
            NightProduct(name: "ORS Sachets", emoji: "🧂", price: 20),
            NightProduct(name: "Digital Thermometer", emoji: "🌡️", price: 250),
            NightProduct(name: "Antiseptic Cream", emoji: "🩹", price: 90)
        ],
        .babyCare: [
            NightProduct(name: "Diapers (Pack of 10)", emoji: "👶", price: 320),
            NightProduct(name: "Baby Formula", emoji: "🍼", price: 480),
            NightProduct(name: "Baby Wipes", emoji: "🧻", price: 150)
        ],
        .essentials: [
            NightProduct(name: "Drinking Water 1L", emoji: "💧", price: 20),
            NightProduct(name: "Phone Charging Cable", emoji: "🔌", price: 199),
            NightProduct(name: "Sanitary Pads", emoji: "🩹", price: 90),
            NightProduct(name: "Torch + Batteries", emoji: "🔦", price: 220)
        ],
        .groceryNight: [
            NightProduct(name: "Bread", emoji: "🍞", price: 40),
            NightProduct(name: "Milk 1L", emoji: "🥛", price: 45),
            NightProduct(name: "Instant Noodles", emoji: "🍜", price: 25)
        ]
    ]

    func vendors(withinKm radius: Double, category: NightCategory?, at date: Date = Date()) -> [NightVendor] {
        Self.allVendors
            .filter { $0.isOpenNow(at: date) }
            .filter { category == nil || $0.category == category }
            .filter { $0.distanceKm <= radius }
            .sorted { $0.distanceKm < $1.distanceKm }
    }

    func products(for vendor: NightVendor) -> [NightProduct] {
        Self.productCatalog[vendor.category] ?? []
    }
}
