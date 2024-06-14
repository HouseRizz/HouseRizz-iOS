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
