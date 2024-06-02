//
//  CartProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartProductView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    let cartItem: CartItem

    var body: some View {
        HStack(spacing: 20) {
            Image(cartItem.product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 110)
                .cornerRadius(20)

            VStack(alignment: .leading) {
                Text(cartItem.product.name)
                    .font(.headline)
                    .bold()
                
                Text("₹\(cartItem.product.price * cartItem.quantity)")
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

#Preview {
    CartProductView(cartItem: CartItem(product: HRProduct(category: Category.tv, name: "Retro TV", image: "retrotv", description: "Vintage-style retro TV for nostalgic moments. Transport yourself back in time with this charming retro TV. Its classic design evokes memories of simpler days. Enjoy your favorite movies and shows with modern technology in a nostalgic package. Available in compact sizes for easy placement in any room.", supplier: "Apple", price: 150, width: "32 inches", height: "24 inches", diameter: "40 inches"), quantity: 2))
}
