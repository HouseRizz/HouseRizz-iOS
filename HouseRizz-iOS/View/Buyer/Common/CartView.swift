//
//  CartView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var authViewModel = Authentication()
    
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
                
                if let user = authViewModel.user {
                    HRCartButton(buttonText: "Proceed to Checkout", action: {
                        cartViewModel.sendOrder(buyerName: user.name, buyerEmail: user.email, buyerPhoneNumber: user.phoneNumber, buyerAddress: user.address)
                    })
                    .padding()
                } else {
                    Text("Loading ..")
                        .foregroundStyle(.gray)
                }
                
                
                
            } else {
                Text("Your Cart is Empty")
            }
        }
        .navigationTitle("My Cart")
        .padding(.vertical)
        .onAppear {
            authViewModel.fetchUser()
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
}
