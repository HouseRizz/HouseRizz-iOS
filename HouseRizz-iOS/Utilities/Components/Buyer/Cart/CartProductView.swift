//
//  CartProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartProductView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    let cartItem: HRCartItem

    var body: some View {
        HStack(spacing: 20) {
            if let url = cartItem.product.imageURL1Value {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 110)
                            .cornerRadius(15)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 90, height: 110)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 110)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            

            VStack(alignment: .leading) {
                Text(cartItem.product.name)
                    .font(.caption)
                    .bold()
                
                Text(((cartItem.product.price ?? 0) * Double(cartItem.quantity)).formattedCurrency())
                    .font(.subheadline)
            }
            
            Spacer()
            
            HStack{
                
                if cartItem.quantity == 1 {
                    Button(action: {
                        cartViewModel.removeFromCart(product: cartItem.product)
                    }) {
                        Image(systemName: "x.square")
                            .foregroundStyle(.orange.opacity(0.8))
                    }
                } else {
                    Button(action: {
                        cartViewModel.updateCartItemQuantity(cartItem: cartItem, newQuantity: cartItem.quantity - 1)
                    }) {
                        Image(systemName: "minus.square")
                            .foregroundStyle(.orange.opacity(0.8))
                    }
                }
                
                Spacer()

                Text("\(cartItem.quantity)")
                    .font(.headline)
                
                Spacer()

                Button(action: {
                    cartViewModel.updateCartItemQuantity(cartItem: cartItem, newQuantity: cartItem.quantity + 1)
                }) {
                    Image(systemName: "plus.square.fill")
                        .foregroundStyle(.orange.opacity(0.8))
                }
            }
            .frame(width: 80)

            
        }
        .padding(.horizontal)
        .background(.orange.opacity(0.2))
        .cornerRadius(12)
        .frame(minWidth: .none)
        .padding()
    }
}
