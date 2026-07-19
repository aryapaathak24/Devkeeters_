//
//  RootTabView.swift
//  Devkeeters_26
//
//  App root. pantry_home and predicted_basket_home both list "tab_bar"
//  explicitly as an entryPoint in their flow JSONs, so those get tabs.
//  Night Mode's JSON does NOT list tab_bar (only home_screen_banner /
//  auto_prompt_after_10pm), so it stays a banner on the Home tab instead
//  — see NightModeToggleBanner usage in ContentView.
//

import SwiftUI

struct RootTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.theme.surfaceContainerLow)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack { ContentView() }
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { PantryHomeView() }
                .tabItem { Label("Pantry", systemImage: "cabinet.fill") }

            NavigationStack { PredictedBasketHomeView() }
                .tabItem { Label("Baskets", systemImage: "cart.fill.badge.clock") }

            NavigationStack { VendorListView() }
                .tabItem { Label("Menu", systemImage: "tag.fill") }
        }
        .tint(Color.theme.primary)
    }
}

#Preview {
    RootTabView()
}
