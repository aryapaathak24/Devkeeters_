//
//  CartValueSummaryView.swift
//  Devkeeters_26
//
//  cart_value_summary screen. Checkout reuses
//  OrderingCoordinator.shared.placeOrder(summary:) unmodified — see
//  MenuAdvisorViewModel.checkout(). A successful checkout here also drives
//  the live-tracking section on the Home tab, since both read the same
//  OrderingCoordinator.shared.state.
//

import SwiftUI

struct CartValueSummaryView: View {
    let viewModel: MenuAdvisorViewModel

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    ForEach(viewModel.cart, id: \.self) { item in
                        HStack {
                            Text("\(item.emoji) \(item.name)")
                            Spacer()
                            Text("₹\(item.price)")
                        }
                    }
                }

                Section {
                    if viewModel.totalSavings > 0 {
                        HStack {
                            Text("Combo savings").foregroundStyle(Color.theme.success)
                            Spacer()
                            Text("-₹\(viewModel.totalSavings)").foregroundStyle(Color.theme.success)
                        }
                    }
                    HStack {
                        Text("Total").font(.theme.headlineMd)
                        Spacer()
                        Text("₹\(viewModel.cartTotal)").font(.theme.headlineMd)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)

            if let error = viewModel.lastErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(Color.theme.errorColor)
                    .padding(.horizontal)
            }

            Button(viewModel.coordinatorState == .placing ? "Placing…" : "Checkout") {
                viewModel.checkout()
            }
            .buttonStyle(.themePrimary)
            .padding()
            .disabled(viewModel.cart.isEmpty || viewModel.coordinatorState == .placing)
        }
        .background(Color.theme.background)
        .navigationTitle("Your Cart")
        .navigationBarTitleDisplayMode(.inline)
    }
}
