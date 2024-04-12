//
//  CartProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    var product: HRProduct
    
    var body: some View {
        HStack(spacing: 20) {
            Image(product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70)
                .cornerRadius(9)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(product.name)
                    .bold()
                
                Text("₹ \(product.price)")
                    .bold()
            }
            .padding()
            
            Spacer()
            
            Image(systemName: "trash")
                .foregroundStyle(.red)
                .onTapGesture {
                    cartViewModel.removeToCart(product: product)
                }
        }
        .padding(.horizontal)
        .background(.purple.opacity(0.2))
        .frame(width: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview {
    CartProductView(product: productList[2])
}
