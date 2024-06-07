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
        VStack {
            if !cartViewModel.products.isEmpty {
                ScrollView {
                    ForEach(cartViewModel.products, id: \.product.id) { cartItem in
                        CartProductView(cartItem: cartItem)
                            .environmentObject(cartViewModel)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Your Total is ")
                    Spacer()
                    Text("₹\(cartViewModel.total)")
                        .bold()
                }
                .padding()
                
                HRCartButton(buttonText: "Proceed to Checkout", action: {
                    
                })
                .padding()
                
            } else {
                Text("Your Cart is Empty")
            }
        }
        .navigationTitle("My Cart")
        .padding(.vertical)
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
}
