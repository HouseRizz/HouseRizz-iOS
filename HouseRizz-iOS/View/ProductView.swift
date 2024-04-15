//
//  ProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/04/24.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("New Arrivals")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "circle.grid.2x2.fill")
                    .foregroundStyle(.purple.opacity(0.2))
            }
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(productList, id: \.id) {product in
                        NavigationLink{
                            ProductDetailsView(product: product)
                        } label: {
                            ProductCardView(product: product)
                                .environmentObject(cartViewModel)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ProductView()
}
