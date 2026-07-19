//
//  VendorListView.swift
//  Devkeeters_26
//
//  Menu tab root — satisfies vendor_menu's "vendor_list" entryPoint.
//

import SwiftUI

struct VendorListView: View {
    @State private var viewModel = MenuAdvisorViewModel()

    var body: some View {
        List(viewModel.vendors) { vendor in
            NavigationLink(value: vendor) {
                HStack(spacing: 12) {
                    Text(vendor.cuisineEmoji).font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vendor.name).font(.theme.bodyMd.weight(.semibold)).foregroundStyle(Color.theme.onSurface)
                        Text("\(vendor.combos.count) combo deal\(vendor.combos.count == 1 ? "" : "s")")
                            .font(.theme.labelSm)
                            .foregroundStyle(Color.theme.onSurfaceVariant)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.theme.background)
        .tint(Color.theme.primary)
        .navigationTitle("Menu")
        .navigationDestination(for: AdvisorVendor.self) { vendor in
            VendorMenuView(vendor: vendor, viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationStack { VendorListView() }
}
