//
//  OrderActivityAttributes.swift
//  Devkeeters_26
//
//  One shared Live Activity template for all three domains (see
//  05_DESIGN_SYSTEM.md) — domain/title are fixed for the life of the
//  activity, statusText/etaMinutes/progress update as the mock order moves.
//
//  This file must also be added to the OrderLiveActivityWidget extension
//  target once it exists (Target Membership in the File Inspector), since
//  ActivityAttributes has to be visible to both the app and the widget.
//

import ActivityKit

struct OrderActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var statusText: String
        var etaMinutes: Int?
        var progress: Double
    }

    var domain: ServiceDomain
    var title: String
}
