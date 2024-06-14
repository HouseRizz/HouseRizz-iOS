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
    @State private var showAlert = false
    
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
                    Text((cartViewModel.total).formattedCurrency())
                        .bold()
                }
                .padding()
                
                if let user = authViewModel.user {
                    NavigationLink(destination: UPIView()) {
                        Text("Proceed to Checkout")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryColor)
                            .cornerRadius(10)
                            .padding()
                    }
//                    HRCartButton(buttonText: "Proceed to Checkout", action: {
//                        cartViewModel.sendOrder(buyerName: user.name, buyerEmail: user.email, buyerPhoneNumber: user.phoneNumber, buyerAddress: user.address)
//                        showAlert = true
//                    })
//                    .padding()
//                    .alert(isPresented: $showAlert) {
//                        Alert(title: Text("Order Sent"),
//                              message: Text("Your order has been sent successfully."),
//                              dismissButton: .default(Text("OK"), action: {
//                            cartViewModel.clearCart()
//                        }))
//                    }
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
