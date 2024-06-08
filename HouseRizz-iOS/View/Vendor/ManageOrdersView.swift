//
//  ManageOrdersView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import SwiftUI

struct ManageOrdersView: View {
    
    @StateObject private var viewModel = ManageOrdersViewModel()
    
    var body: some View {
        VStack {
            List(viewModel.orders, id: \.self) { order in
                OrderListItemView(order: order)
            }
        }
        .navigationTitle("Manage Orders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchOrders()
        }
    }
}

#Preview {
    ManageOrdersView()
}
