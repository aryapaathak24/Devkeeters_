//
//  ContentView.swift
//  Devkeeters_26
//
//  Real touch-fallback UI. Goes through OrderViewModel -> OrderingCoordinator
//  only — never touches the brain or ZomatoService directly (strict MVVM).
//  Siri uses PlaceZomatoOrderIntent / OrderMyUsualIntent, which call the
//  same OrderingCoordinator.
//
//  Visual language: "Pale Earth & Glass" — see Devkeeters_26/DesignSystem/.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var viewModel = OrderViewModel()
    @State private var showManageUsual = false
    @State private var nightModeViewModel = NightModeViewModel()
    @State private var showNightMode = false
    @State private var showFeatures = false

    var body: some View {
        ScrollView {
            VStack(spacing: ThemeMetrics.spacingMD) {

                // ── Header ────────────────────────────────────────────
                header

                // ── Decorative voice mark ──────────────────────────────
                micMark

                // ── Night Emergency Mode banner ────────────────────────
                nightModeBanner

                // ── My Usual card (shows after first save/order) ──────
                if let usual = viewModel.savedOrder {
                    usualCard(usual)
                } else {
                    setUsualBanner
                }

                // ── New order section ─────────────────────────────────
                orderSection

                // ── Live tracking ─────────────────────────────────────
                statusSection

                siriTip

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color.theme.background)
        .sheet(isPresented: $showManageUsual) {
            ManageUsualView(current: viewModel.savedOrder) { newOrder in
                viewModel.saveCustomUsual(from: newOrder)
            }
        }
        .sheet(isPresented: $showFeatures) {
            AdvancedIntelligenceView()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .navigationDestination(isPresented: $showNightMode) {
            NightCatalogView()
        }
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
                hasSeenOnboarding = true
            }
        }
    }

    // MARK: - Night Mode Banner

    private var nightModeBanner: some View {
        NightModeToggleBanner(
            isAutoSuggested: nightModeViewModel.shouldShowAutoSuggestion(),
            onEnable: { showNightMode = true },
            onDismiss: { nightModeViewModel.dismissAutoSuggestion() }
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                Text("Cortex")
                    .font(.theme.headlineLg)
            }
            .foregroundStyle(Color.theme.onSurface)

            Spacer()

            HStack(spacing: 12) {
                Button { showFeatures = true } label: {
                    Image(systemName: "sparkles")
                }
                Button { showOnboarding = true } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
            .font(.title3)
            .foregroundStyle(Color.theme.onSurface)
        }
    }

    // MARK: - Decorative mic mark

    /// Purely decorative — illustrates the Siri voice concept (matches the
    /// mock's mic circle). No in-app voice capture is wired to it.
    private var micMark: some View {
        ZStack {
            Circle()
                .fill(Color.theme.surfaceContainer)
                .frame(width: 120, height: 120)
            Image(systemName: "mic.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.theme.primary)
        }
        .padding(.vertical, ThemeMetrics.spacingBase)
    }

    // MARK: - Set Usual Banner (first-time, no usual saved)

    private var setUsualBanner: some View {
        Button { showManageUsual = true } label: {
            HStack(spacing: 14) {
                IconBadge(systemImage: "star.fill")

                VStack(alignment: .leading, spacing: 3) {
                    Text("Set your usual order")
                        .font(.theme.bodyMd.weight(.semibold))
                        .foregroundStyle(Color.theme.onSurface)
                    Text("Tap to pick items — then just say \"Hey Siri, order my Zomato usual\"")
                        .font(.footnote)
                        .foregroundStyle(Color.theme.onSurfaceVariant)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.theme.outline)
            }
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - My Usual Card

    private func usualCard(_ order: SavedOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            // Top row
            HStack {
                Text("My Usual · Zomato")
                    .font(.theme.headlineMd)
                    .foregroundStyle(Color.theme.onSurface)
                Spacer()
                Button("Edit") { showManageUsual = true }
                    .buttonStyle(.themeGhost)
            }

            // Restaurant
            HStack(spacing: 6) {
                Image(systemName: "fork.knife")
                    .foregroundStyle(Color.theme.onSurfaceVariant)
                Text(order.restaurantName)
                    .font(.theme.bodyMd.weight(.semibold))
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }

            // Items as chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(order.items, id: \.self) { item in
                        let emoji = MenuItem.all.first {
                            $0.name.lowercased() == item.lowercased()
                        }?.emoji ?? "🍽️"

                        PillChip(text: "\(emoji) \(item)")
                    }
                }
            }

            Divider().overlay(Color.theme.outlineVariant)

            // Price + ETA
            HStack {
                Text("₹\(order.totalPrice)")
                    .font(.theme.headlineMd)
                    .foregroundStyle(Color.theme.onSurface)
                Spacer()
                Label("\(order.etaMinutes) min ETA", systemImage: "clock")
                    .font(.footnote)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }

            // Order Again button
            Button {
                Task { await viewModel.reorderUsual() }
            } label: {
                Label(
                    viewModel.coordinatorState == .placing ? "Placing…" : "Order Again",
                    systemImage: "bag.fill"
                )
            }
            .buttonStyle(.themePrimary)
            .disabled(viewModel.isSubmitting)
        }
        .glassCard()
    }

    // MARK: - New Order Section

    private var orderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order anything")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)

            TextField("e.g. butter chicken and naan", text: $viewModel.orderText, axis: .vertical)
                .font(.theme.bodyMd)
                .lineLimit(1...3)
                .disabled(viewModel.isSubmitting)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: ThemeMetrics.radiusDefault)
                        .fill(Color.theme.surfaceContainer)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeMetrics.radiusDefault)
                        .strokeBorder(Color.theme.outlineVariant, lineWidth: 1)
                )

            Button {
                Task { await viewModel.submit() }
            } label: {
                if viewModel.isSubmitting {
                    ProgressView().tint(Color.theme.onPrimary)
                } else {
                    Text("Order with Cortex")
                }
            }
            .buttonStyle(.themePrimary)
            .disabled(viewModel.orderText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSubmitting)

            if let error = viewModel.lastErrorMessage {
                Text(error).font(.footnote).foregroundStyle(Color.theme.errorColor)
            }

            Text("This order will auto-save as your new usual")
                .font(.theme.labelSm)
                .foregroundStyle(Color.theme.outline)
        }
        .glassCard()
    }

    // MARK: - Live Tracking Section

    @ViewBuilder
    private var statusSection: some View {
        switch viewModel.coordinatorState {
        case .idle:
            EmptyView()
        case .placing:
            HStack {
                ProgressView().tint(Color.theme.primary)
                Text("Placing your order…")
                    .foregroundStyle(Color.theme.onSurfaceVariant)
            }
            .padding()
        case .active(let statusText, let progress, let etaMinutes):
            VStack(alignment: .leading, spacing: 10) {
                Text("Live Tracking")
                    .font(.theme.headlineMd)
                    .foregroundStyle(Color.theme.onSurface)

                // Status steps row
                HStack(spacing: 0) {
                    ForEach(["Placed", "Preparing", "On the way", "Delivered"], id: \.self) { step in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(statusText.lowercased().contains(step.lowercased().prefix(5))
                                      ? Color.theme.primary : Color.theme.outlineVariant)
                                .frame(width: 10, height: 10)
                            Text(step)
                                .font(.system(size: 9))
                                .foregroundStyle(Color.theme.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        if step != "Delivered" {
                            Rectangle()
                                .fill(Color.theme.outlineVariant)
                                .frame(height: 1)
                                .padding(.bottom, 14)
                        }
                    }
                }

                ProgressView(value: progress)
                    .tint(Color.theme.primary)
                    .animation(.easeInOut(duration: 0.5), value: progress)

                if let etaMinutes {
                    Label("\(etaMinutes) min remaining", systemImage: "clock")
                        .font(.footnote)
                        .foregroundStyle(Color.theme.onSurfaceVariant)
                }
            }
            .glassCard()

        case .failed(let message):
            Text(message).font(.footnote).foregroundStyle(Color.theme.errorColor).padding()
        }
    }

    // MARK: - Siri tip

    private var siriTip: some View {
        HStack(spacing: 6) {
            Image(systemName: "mic.fill")
            Text("\"Hey Siri, order my Zomato usual from Cortex\"")
                .italic()
        }
        .font(.theme.labelSm)
        .foregroundStyle(Color.theme.onSurfaceVariant)
    }
}

#Preview {
    ContentView()
}
