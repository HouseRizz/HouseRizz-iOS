//
//  CartView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        ScrollView {
            if !cartViewModel.products.isEmpty {
                ForEach(cartViewModel.products, id: \.product.id) { cartItem in
                    CartProductView(cartItem: cartItem)
                        .environmentObject(cartViewModel)
                }

                HStack {
                    Text("Your Total is ")
                    Spacer()
                    Text("₹\(cartViewModel.total)")
                        .bold()
                }
                .padding()
            } else {
                Text("Your Cart is Empty")
            }
        }
        .navigationTitle("My Cart")
        .padding(.top)
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
}
