//
//  OrderLiveActivityWidget.swift
//  OrderLiveActivityWidget
//
//  The one shared Live Activity template for all three domains (see
//  05_DESIGN_SYSTEM.md): domain label (muted) + title (bold) + status +
//  optional ETA, same layout regardless of which domain triggered it. Never
//  redesign this per domain — only OrderDomainIcon/displayName branch on it.
//

import ActivityKit
import WidgetKit
import SwiftUI

// "Pale Earth & Glass" umber accent + linen background — kept as local
// constants (rather than importing the app target's DesignSystem/Theme.swift)
// so this widget extension target has no cross-target source dependency.
private let orderAccent = Color(red: 0x4E / 255, green: 0x34 / 255, blue: 0x2E / 255)
private let orderBackgroundTint = Color(red: 0xF9 / 255, green: 0xF9 / 255, blue: 0xF6 / 255)

struct OrderLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            LockScreenOrderView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(orderBackgroundTint)
                .activitySystemActionForegroundColor(orderAccent)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    OrderDomainIcon(domain: context.attributes.domain)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let eta = context.state.etaMinutes {
                        Text("\(eta) min")
                            .font(.headline)
                            .foregroundStyle(orderAccent)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.domain.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(context.attributes.title)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(context.state.statusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ProgressView(value: context.state.progress)
                            .tint(orderAccent)
                    }
                }
            } compactLeading: {
                OrderDomainIcon(domain: context.attributes.domain)
            } compactTrailing: {
                if let eta = context.state.etaMinutes {
                    Text("\(eta)m")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(orderAccent)
                } else {
                    ProgressView(value: context.state.progress)
                        .progressViewStyle(.circular)
                        .tint(orderAccent)
                }
            } minimal: {
                OrderDomainIcon(domain: context.attributes.domain)
            }
            .keylineTint(orderAccent)
        }
    }
}

private struct LockScreenOrderView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                OrderDomainIcon(domain: attributes.domain)
                Text(attributes.domain.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let eta = state.etaMinutes {
                    Text("\(eta) min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(orderAccent)
                }
            }

            Text(attributes.title)
                .font(.headline)
                .lineLimit(1)

            Text(state.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: state.progress)
                .tint(orderAccent)
        }
        .padding(16)
    }
}

private struct OrderDomainIcon: View {
    let domain: ServiceDomain

    var body: some View {
        Image(systemName: domain.symbolName)
            .foregroundStyle(orderAccent)
    }
}

private extension ServiceDomain {
    var displayName: String {
        switch self {
        case .zomato: "Zomato"
        case .blinkit: "Blinkit"
        case .district: "District"
        }
    }

    var symbolName: String {
        switch self {
        case .zomato: "fork.knife"
        case .blinkit: "cart"
        case .district: "calendar"
        }
    }
}
