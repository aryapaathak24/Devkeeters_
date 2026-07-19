//
//  CortexShortcuts.swift
//  Devkeeters_26
//
//  Registers all Cortex Siri invocation phrases. App Shortcuts (App Intents
//  framework, iOS 16+) auto-expose to Siri/Spotlight/Shortcuts with no
//  separate Intents extension target, no NSSiriUsageDescription, and no
//  Siri capability entitlement.
//
//  HOW THE KEYWORD WORKS
//  ─────────────────────
//  \(.applicationName) → "Cortex" at runtime → the app-name keyword.
//  "Zomato" in the phrase is a static service keyword, just like saying
//  "order my usual on Zomato" routes to the real Zomato app — here it
//  signals which service domain the user means.
//
//  Phrase breakdown:
//    "Hey Siri" → wakes Siri
//    "order my Zomato usual" → command + service keyword
//    "from Cortex" → app keyword → routes to this app
//

import AppIntents

struct CortexShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {

        // ── Shortcut 1: New order via text ────────────────────────────────
        // Two-turn: Siri asks "What would you like to order?" after phrase.
        AppShortcut(
            intent: PlaceZomatoOrderIntent(),
            phrases: [
                "Order food with \(.applicationName)",
                "Order with \(.applicationName)"
            ],
            shortTitle: "Order Food",
            systemImageName: "fork.knife"
        )

        // ── Shortcut 2: Reorder my usual (keyword = "Zomato") ─────────────
        // One-shot: no follow-up question — uses last saved order directly.
        // Say: "Hey Siri, order my Zomato usual from Cortex"
        AppShortcut(
            intent: OrderMyUsualIntent(),
            phrases: [
                "Order my Zomato usual from \(.applicationName)",
                "Order my usual on Zomato from \(.applicationName)",
                "Reorder my Zomato from \(.applicationName)",
                "Reorder from Zomato with \(.applicationName)"
            ],
            shortTitle: "Order My Usual",
            systemImageName: "arrow.clockwise"
        )

        // ── Shortcut 3: Night Emergency Mode (read-only, no side effect) ──
        AppShortcut(
            intent: GetNightHelpIntent(),
            phrases: [
                "What's open near me with \(.applicationName)",
                "Night help from \(.applicationName)"
            ],
            shortTitle: "Night Help",
            systemImageName: "moon.stars.fill"
        )

        // ── Shortcut 4: Menu & Pricing Advisor combo deals ────────────────
        AppShortcut(
            intent: FindComboDealIntent(),
            phrases: [
                "Find me a combo deal with \(.applicationName)",
                "Any deals with \(.applicationName)"
            ],
            shortTitle: "Find Combo Deal",
            systemImageName: "tag.fill"
        )

        // ── Shortcut 5: Predicting Baskets ─────────────────────────────────
        AppShortcut(
            intent: GetPredictedBasketIntent(),
            phrases: [
                "What's my basket this week from \(.applicationName)",
                "Show my predicted basket with \(.applicationName)"
            ],
            shortTitle: "Predicted Basket",
            systemImageName: "cart.fill.badge.clock"
        )

        // ── Shortcut 6: PantryLens ──────────────────────────────────────────
        AppShortcut(
            intent: CheckPantryIntent(),
            phrases: [
                "What am I low on with \(.applicationName)",
                "Check my pantry with \(.applicationName)"
            ],
            shortTitle: "Check Pantry",
            systemImageName: "cabinet.fill"
        )
    }
}
