//
//  OrderSummary.swift
//  Devkeeters_26
//
//  Shared result shape every domain service reports back through, so the
//  Live Activity template stays domain-agnostic (see 03_ARCHITECTURE.md).
//

struct OrderSummary {
    var domain: ServiceDomain
    var title: String
    var initialStatus: String
    var etaMinutes: Int?
}
