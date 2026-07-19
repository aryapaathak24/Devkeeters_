//
//  AdvancedIntelligenceView.swift
//  Devkeeters_26
//
//  Informational feature spotlight, matching the "Advanced Intelligence
//  Features" mock — trimmed to only the 4 features that are actually
//  shipped (Crew Mode / Deal Radar from the mock are out of scope, see
//  the SRS memory). Presented as a sheet from ContentView's header icon;
//  it does not route into the real feature screens, only dismisses.
//

import SwiftUI

private struct FeatureSpotlight: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private let features: [FeatureSpotlight] = [
    FeatureSpotlight(
        icon: "eye",
        title: "PantryLens",
        description: "Scans what you have, flags what's low. Never run out of essentials again."
    ),
    FeatureSpotlight(
        icon: "basket",
        title: "Predictive Baskets",
        description: "Auto-builds your usual order based on habits and consumption rates."
    ),
    FeatureSpotlight(
        icon: "moon.stars",
        title: "Night Mode",
        description: "Filters to what's actually open right now for late-night cravings."
    ),
    FeatureSpotlight(
        icon: "lightbulb",
        title: "Menu Advisor",
        description: "Best-value picks and pricing insights to stretch your budget."
    ),
]

struct AdvancedIntelligenceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemeMetrics.spacingMD) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("NEW FEATURES")
                        .font(.theme.labelSm)
                        .foregroundStyle(Color.theme.outline)

                    Text("Advanced Intelligence")
                        .font(.theme.headlineLg)
                        .foregroundStyle(Color.theme.onSurface)

                    Text("Experience a smarter, more intuitive way to manage your household. These tools anticipate your needs and simplify your daily routines.")
                        .font(.theme.bodyMd)
                        .foregroundStyle(Color.theme.onSurfaceVariant)
                }

                ForEach(features) { feature in
                    HStack(alignment: .top, spacing: 14) {
                        IconBadge(systemImage: feature.icon, diameter: 44)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.title)
                                .font(.theme.headlineMd)
                                .foregroundStyle(Color.theme.onSurface)
                            Text(feature.description)
                                .font(.theme.bodyMd)
                                .foregroundStyle(Color.theme.onSurfaceVariant)
                        }
                    }
                    .glassCard()
                }

                Button("Done") { dismiss() }
                    .buttonStyle(.themePrimary)
                    .padding(.top, ThemeMetrics.spacingBase)
            }
            .padding()
        }
        .background(Color.theme.background)
    }
}

#Preview {
    AdvancedIntelligenceView()
}
