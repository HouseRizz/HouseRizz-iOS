//
//  OrderDetailView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 09/06/24.
//

import SwiftUI

struct OrderDetailView: View {
    
    let order: HROrder
    
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
                
                Spacer()
            }
            .padding()
            .cornerRadius(20)
            .offset(y: -30)
        }
    }
}
