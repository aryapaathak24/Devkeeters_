//
//  LiveOrderActivity.swift
//  Devkeeters_26
//
//  Starts/updates/ends the one shared Live Activity, regardless of which
//  domain triggered it (see 03_ARCHITECTURE.md's feedback layer).
//

import ActivityKit

enum LiveOrderActivity {
    private static var current: Activity<OrderActivityAttributes>?

    static func start(for summary: OrderSummary) throws {
        let attributes = OrderActivityAttributes(domain: summary.domain, title: summary.title)
        let initialState = OrderActivityAttributes.ContentState(
            statusText: summary.initialStatus,
            etaMinutes: summary.etaMinutes,
            progress: 0
        )
        current = try Activity.request(
            attributes: attributes,
            content: .init(state: initialState, staleDate: nil)
        )
    }

    static func update(statusText: String, etaMinutes: Int?, progress: Double) async {
        guard let current else { return }
        let state = OrderActivityAttributes.ContentState(
            statusText: statusText,
            etaMinutes: etaMinutes,
            progress: progress
        )
        await current.update(.init(state: state, staleDate: nil))
    }

    static func end() async {
        guard let current else { return }
        await current.end(nil, dismissalPolicy: .default)
        Self.current = nil
    }
}
