//
//  CartProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    let cartItem: CartItem

    var body: some View {
        HStack(spacing: 20) {
            Image(cartItem.product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .cornerRadius(9)

            Text(cartItem.product.name)
                .font(.caption2)

            HStack{
                
                if cartItem.quantity == 1 {
                    Button(action: {
                        cartViewModel.removeFromCart(product: cartItem.product)
                    }) {
                        Image(systemName: "x.square")
                            .foregroundStyle(.purple.opacity(0.8))
                    }
                } else {
                    Button(action: {
                        cartViewModel.updateCartItemQuantity(cartItem: cartItem, newQuantity: cartItem.quantity - 1)
                    }) {
                        Image(systemName: "minus.square")
                            .foregroundStyle(.purple.opacity(0.8))
                    }
                }
                
                Spacer()

                Text("\(cartItem.quantity)")
                    .font(.caption2)
                
                Spacer()

                Button(action: {
                    cartViewModel.updateCartItemQuantity(cartItem: cartItem, newQuantity: cartItem.quantity + 1)
                }) {
                    Image(systemName: "plus.square.fill")
                        .foregroundStyle(.purple.opacity(0.8))
                }
            }
            .frame(width: 80)

            Text("₹\(cartItem.product.price * cartItem.quantity)")
                .font(.caption2)
        }
        .padding(.horizontal)
        .background(.purple.opacity(0.2))
        .cornerRadius(12)
        .frame(minWidth: .none)
        .padding()
    }
}
