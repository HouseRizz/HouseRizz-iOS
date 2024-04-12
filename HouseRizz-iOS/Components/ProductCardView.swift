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
        ZStack {
            Color.blue.opacity(0.2)
            
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading) {
                    Image(product.image)
                        .resizable()
                        .frame(width: 175,height: 160)
                        .cornerRadius(12)
                    
                    Text(product.name)
                        .font(.headline)
                        .padding(.vertical, 1)
                    
                    Text(product.supplier)
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .padding(.vertical,0.5)
                    
                    Text("₹ \(product.price)")
                        .bold()
                }
                
                Button{
                    cartViewModel.addToCart(product: product)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 35,height: 35)
                        .foregroundStyle(.black)
                        .padding(.trailing)
                }
            }
        }
        .frame(width: 185, height: 260)
        .cornerRadius(15)
    }
}

#Preview {
    ProductCardView(product: productList[3])
}
