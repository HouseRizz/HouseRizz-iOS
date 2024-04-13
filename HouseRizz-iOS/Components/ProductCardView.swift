//
//  ProductCardView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct ProductCardView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    var product: HRProduct
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                Image(product.image)
                    .resizable()
                    .frame(width: 175,height: 160)
                    .cornerRadius(12)
                
                Text(product.name)
                    .font(.subheadline)
                    .padding(.vertical, 1)
                    .foregroundStyle(.black)
                
                Text("₹ \(product.price)")
                    .font(.caption2)
                    .foregroundStyle(.black)
            }
            
            Button{
                cartViewModel.addToCart(product: product)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 25,height: 25)
                    .foregroundStyle(.black)
                    .padding(.trailing)
            }
        }
        .frame(width: 185, height: 260)
        .cornerRadius(15)
    }
}

#Preview {
    ProductCardView(product: productList[3])
}
