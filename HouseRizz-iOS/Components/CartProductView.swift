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

            HStack(spacing: 10) {
                if cartItem.quantity == 1 {
                    Button(action: {
                        cartViewModel.removeFromCart(product: cartItem.product)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.purple.opacity(0.8))
                            .frame(width: 5, height: 5)
                    }
                } else {
                    Button(action: {
                        cartViewModel.updateCartItemQuantity(cartItem: cartItem, newQuantity: cartItem.quantity - 1)
                    }) {
                        Image(systemName: "minus")
                            .foregroundStyle(.purple.opacity(0.8))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Spacer()

                Text("\(cartItem.quantity)")
                    .font(.caption2)
                    .foregroundStyle(.black)
                
                Spacer()

                Button(action: {
                    cartViewModel.updateCartItemQuantity(cartItem: cartItem, newQuantity: cartItem.quantity + 1)
                }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.purple.opacity(0.8))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )

            Text("₹ \(cartItem.product.price * cartItem.quantity)")
                .font(.caption2)
        }
        .padding(.horizontal)
        .background(.purple.opacity(0.2))
        .cornerRadius(12)
        .frame(minWidth: .none)
        .padding()
    }
}
