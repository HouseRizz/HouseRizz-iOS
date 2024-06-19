//
//  AdminOrdersView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI

struct AdminOrdersView: View {
    @StateObject private var viewModel = AdminOrdersViewModel()
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
            .navigationTitle("Manage All Orders")
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
                viewModel.fetchOrders()
            }
            .refreshable {
                viewModel.fetchOrders()
            }
        }
    }
}

#Preview {
    AdminOrdersView()
}
