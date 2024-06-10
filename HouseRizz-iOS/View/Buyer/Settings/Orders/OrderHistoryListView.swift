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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.orders, id: \.self) { order in
                    if let user = authentication.user {
                        NavigationLink {
                            OrderHistoryDetailView(order: order).toolbarRole(.editor)
                        } label: {
                            OrderListItemView(order: order)
                        }
                    } else {
                        Text("Not Signed In")
                    }
                }
            }
            .navigationTitle("Orders History")
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
                viewModel.fetchOrders(buyerName: authentication.user?.name ?? "Not Signed In")
            }
            .refreshable {
                viewModel.fetchOrders(buyerName: authentication.user?.name ?? "Not Signed In")
            }
        }
    }
}

#Preview {
    OrderHistoryListView()
}
