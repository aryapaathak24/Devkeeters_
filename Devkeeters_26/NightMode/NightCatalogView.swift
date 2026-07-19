//
//  NightCatalogView.swift
//  Devkeeters_26
//
//  night_catalog screen — filtered, distance-sorted vendor list.
//  No CoreLocation is used anywhere in this app (mock distances only), so
//  the JSON's "location permission denied" error state has no real
//  trigger here and is intentionally not built — see the build plan.
//

import SwiftUI

struct NightCatalogView: View {
    @State private var viewModel = NightModeViewModel()

    var body: some View {
        VStack(spacing: 0) {
            categoryChips

            if viewModel.radiusWasExpanded && !viewModel.vendors.isEmpty {
                Text("Nothing within \(Int(NightModeViewModel.startRadiusKm)) km — expanded to \(Int(viewModel.radiusKm)) km")
                    .font(.theme.labelSm)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
                    .padding(.vertical, 6)
            }

            if viewModel.vendors.isEmpty {
                emptyState
            } else {
                List(viewModel.vendors) { vendor in
                    NavigationLink(value: vendor) {
                        vendorRow(vendor)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.theme.background)
            }
        }
        .background(Color.theme.background)
        .tint(Color.theme.primary)
        .navigationTitle("Night Mode")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: NightVendor.self) { vendor in
            VendorDetailNightView(vendor: vendor, viewModel: viewModel)
        }
        .onAppear { viewModel.loadVendors() }
        .onChange(of: viewModel.selectedCategory) { _, _ in viewModel.loadVendors() }
    }

    // MARK: - Category chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(NightCategory.allCases) { category in
                    chip(title: category.displayName, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.theme.labelSm)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(isSelected ? Color.theme.primary : Color.theme.surfaceContainer))
                .foregroundStyle(isSelected ? Color.theme.onPrimary : Color.theme.onSurface)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 40))
                .foregroundStyle(Color.theme.outline)
            Text("Nothing open nearby")
                .font(.theme.headlineMd)
                .foregroundStyle(Color.theme.onSurface)
            Text("We expanded your search radius to \(Int(viewModel.radiusKm)) km and still found nothing open right now.")
                .font(.theme.bodyMd)
                .foregroundStyle(Color.theme.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Vendor row

    private func vendorRow(_ vendor: NightVendor) -> some View {
        HStack(spacing: 12) {
            Image(systemName: vendor.category.systemImage)
                .font(.title3)
                .foregroundStyle(Color.theme.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(vendor.name).font(.theme.bodyMd.weight(.semibold)).foregroundStyle(Color.theme.onSurface)
                Text(vendor.openUntilText).font(.theme.labelSm).foregroundStyle(Color.theme.onSurfaceVariant)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f km", vendor.distanceKm)).font(.theme.labelSm).foregroundStyle(Color.theme.onSurface)
                Text("\(vendor.etaMinutes) min").font(.theme.labelSm).foregroundStyle(Color.theme.onSurfaceVariant)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { NightCatalogView() }
}
