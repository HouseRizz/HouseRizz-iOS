//
//  OrderHistoryDetailView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 10/06/24.
//

import SwiftUI

struct OrderHistoryDetailView: View {
    
    let order: HROrder
    @Environment(\.presentationMode) var presentationMode
    
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
                
                Text("Order Status: \(order.orderStatus)")
                Text("Order Date: \(Date(timeIntervalSince1970: order.dateOfOrder).formatted(date: .complete, time: .shortened))")
                Text("Buyer: \(order.buyerName)")
                Text("Buyer Email: \(order.buyerEmail)")
                Text("Buyer Phone: \(order.buyerPhoneNumber ?? "None Provided")")
                Text("Buyer Address: \(order.buyerAddress ?? "None Provided")")
                
                Spacer()
            }
            .padding()
            .cornerRadius(20)
            .offset(y: -30)
        }
    }
}

