//
//  RoutedIntent.swift
//  Devkeeters_26
//
//  The brain's structured output. Every entry point (voice, camera, touch)
//  produces one of these; the matching domain's AppIntent takes it from there.
//

import FoundationModels

@Generable
enum ServiceDomain: String, CaseIterable, Codable {
    case zomato
    case blinkit
    case district
}

@Generable
struct RoutedIntent {
    @Guide(description: "Which of the three services this request belongs to: zomato (food ordering), blinkit (groceries), or district (event booking)")
    var domain: ServiceDomain

    @Guide(description: "Plain-language description of what the person wants")
    var summary: String

    @Guide(description: "Concrete extracted items: dish names, grocery items, or event names")
    var items: [String]

    @Guide(description: "Only set if the request clearly fans out to a second domain as well, e.g. \"friends over Friday\" implying both a district booking and a blinkit party cart. Leave nil otherwise.")
    var secondaryAction: SecondaryAction?
}

@Generable
struct SecondaryAction {
    @Guide(description: "The second domain this request also applies to")
    var domain: ServiceDomain

    @Guide(description: "Concrete items for the secondary action")
    var items: [String]
}
