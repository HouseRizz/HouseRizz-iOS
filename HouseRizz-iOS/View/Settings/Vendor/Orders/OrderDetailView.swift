//
//  OrderDetailView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 09/06/24.
//

import SwiftUI

struct OrderDetailView: View {
    
    let order: HROrder
    @StateObject private var viewModel: OrderDetailViewModel
    @Environment(\.presentationMode) var presentationMode

    init(order: HROrder) {
        self.order = order
        if let status = OrderStatus(statusString: order.orderStatus) {
            _viewModel = StateObject(wrappedValue: OrderDetailViewModel(initialStatus: status))
        } else {
            _viewModel = StateObject(wrappedValue: OrderDetailViewModel(initialStatus: .toBeConfirmed))
        }
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: order.imageURL, transaction: .init(animation: .default)) { phase in
                switch phase {
                    case .empty:
                        Image("DefaultProductImage")
                            .resizable()
                            .ignoresSafeArea(edges: .top)
                            .frame(width: 320, height: 250)
                    case .success(let image):
                        image
                            .resizable()
                            .ignoresSafeArea(edges: .top)
                            .frame(width: 320, height: 250)
                    case .failure(_):
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .ignoresSafeArea(edges: .top)
                            .frame(width: 320, height: 250)
                    default:
                        EmptyView()
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(order.name)
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Text(order.price?.formattedCurrency() ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                }
                .padding(.vertical)
                
                HStack {
                    Text("Set Order Status")
                    
                    Spacer()
                    
                    Picker("Status", selection: $viewModel.selectedOrderStatus) {
                        ForEach(OrderStatus.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                }
                
                Text("Vendor: \(order.supplier)")
                Text("Order Date: \(Date(timeIntervalSince1970: order.dateOfOrder).formatted(date: .complete, time: .shortened))")
                Text("Buyer: \(order.buyerName)")
                Text("Buyer Email: \(order.buyerEmail)")
                Text("Buyer Phone: \(order.buyerPhoneNumber ?? "None Provided")")
                Text("Buyer Address: \(order.buyerAddress ?? "None Provided")")
                
                Spacer()
                
                Divider()
                
                if viewModel.isChangedStatus {
                    ProgressView().tint(Color.primaryColor)
                } else {
                    HRCartButton(buttonText: "Confirm Changes") {
                        viewModel.updateOrderStatus(order: order)
                    }
                }
            }
            .padding()
            .cornerRadius(20)
            .offset(y: -30)
            .alert("Status Updates", isPresented: $viewModel.isChangedStatus) {
                Button("Ok", role: .cancel ) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text(viewModel.isChangedStatus ? "Status Updated Successfully" : viewModel.error)
            }
        }
    }
}
