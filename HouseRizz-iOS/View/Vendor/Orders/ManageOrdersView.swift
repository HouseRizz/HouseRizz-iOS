//
//  ManageOrdersView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import SwiftUI

struct ManageOrdersView: View {
    
    @StateObject private var viewModel = ManageOrdersViewModel()
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authentication = Authentication()
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.orders, id: \.self) { order in
                    NavigationLink {
                        OrderDetailView(order: order).toolbarRole(.editor)
                    } label: {
                        OrderListItemView(order: order)
                    }
                    
                }
            }
            .navigationTitle("Manage Orders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                viewModel.fetchOrders(vendorName: authentication.user?.name ?? "none")
            }
            .refreshable {
                viewModel.fetchOrders(vendorName: authentication.user?.name ?? "none")
            }
        }
    }
}

#Preview {
    ManageOrdersView()
}
