//
//  OrderSummary.swift
//  Devkeeters_26
//
//  Shared result shape every domain service reports back through, so the
//  Live Activity template stays domain-agnostic (see 03_ARCHITECTURE.md).
//  Now includes price, restaurant name, and item list for Siri dialogue
//  and LastOrderStore persistence.
//

struct OrderSummary {
    var domain: ServiceDomain
    var title: String           // display string, e.g. "butter chicken, naan"
    var items: [String]         // individual item names, e.g. ["butter chicken", "naan"]
    var restaurantName: String  // e.g. "Spice Garden"
    var totalPrice: Int         // ₹ total, e.g. 420
    var initialStatus: String
    var etaMinutes: Int?
}
