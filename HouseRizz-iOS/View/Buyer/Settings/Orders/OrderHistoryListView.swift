//
//  OrderHistoryListView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 10/06/24.
//

import SwiftUI

struct OrderHistoryListView: View {
    
    @StateObject private var viewModel = OrderHistoryListViewModel()
    @StateObject private var authentication = Authentication()
    
    var body: some View {
        VStack {
            List(viewModel.orders, id: \.self) { order in
                NavigationLink {

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
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            viewModel.fetchOrders(buyerName: authentication.displayName)
        }
        .refreshable {
            viewModel.fetchOrders(buyerName: authentication.displayName)
        }
    }
    
}

#Preview {
    OrderHistoryListView()
}
