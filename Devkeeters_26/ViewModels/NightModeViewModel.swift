//
//  NightModeViewModel.swift
//  Devkeeters_26
//
//  Bridges NightModeService to NightCatalogView. Same
//  @MainActor @Observable, constructor-injected shape as OrderViewModel.
//

import Foundation

@MainActor
@Observable
final class NightModeViewModel {
    static let startRadiusKm = 3.0
    static let maxRadiusKm = 15.0
    static let radiusStepKm = 3.0

    private(set) var vendors: [NightVendor] = []
    private(set) var radiusKm: Double = NightModeViewModel.startRadiusKm
    private(set) var radiusWasExpanded = false
    var selectedCategory: NightCategory?

    private let service: any NightVendorProviding

    init(service: any NightVendorProviding = NightModeService()) {
        self.service = service
    }

    func loadVendors(at date: Date = Date()) {
        var radius = Self.startRadiusKm
        var results = service.vendors(withinKm: radius, category: selectedCategory, at: date)
        var expanded = false

        while results.isEmpty && radius < Self.maxRadiusKm {
            radius += Self.radiusStepKm
            expanded = true
            results = service.vendors(withinKm: radius, category: selectedCategory, at: date)
        }

        radiusKm = radius
        radiusWasExpanded = expanded
        vendors = results
    }

    func products(for vendor: NightVendor) -> [NightProduct] {
        service.products(for: vendor)
    }

    func shouldShowAutoSuggestion(now: Date = Date()) -> Bool {
        let hour = Calendar.current.component(.hour, from: now)
        let isLateNight = hour >= 22 || hour < 6
        return isLateNight && !NightModeStore.shared.wasBannerDismissedToday(now: now)
    }

    func dismissAutoSuggestion() {
        NightModeStore.shared.dismissBannerForToday()
    }
}
