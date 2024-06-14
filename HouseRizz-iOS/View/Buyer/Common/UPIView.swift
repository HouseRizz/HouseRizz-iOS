//
//  UPIView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 14/06/24.
//

import SwiftUI

struct UPIView: View {
    @StateObject private var viewModel = UPIViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var authViewModel = Authentication()
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.installedAppList, id: \.self) { app in
                            UPIListView(model: app, viewModel: viewModel)
                                .padding(.vertical)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                if let user = authViewModel.user {
                    HRCartButton(buttonText: "Pay Now") {
                        viewModel.launchIntentURLFromStr(intent: viewModel.selectedApp, payeeVPA: "9999670308@pz", payeeName: "Krish Mittal", amount: "2", currencyCode: "INR", transactionNote: "UPI Transaction Test")
                        cartViewModel.sendOrder(buyerName: user.name, buyerEmail: user.email, buyerPhoneNumber: user.phoneNumber, buyerAddress: user.address)
                        showAlert = true
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Order Sent"),
                              message: Text("Your order has been sent successfully. Further Confirmation will be in the order history page and over the mail in 24 hours, Make sure to complete the payment in your UPI Application otherwise Order will be rejected"),
                              dismissButton: .default(Text("OK"), action: {
                            cartViewModel.clearCart()
                            presentationMode.wrappedValue.dismiss()
                        }))
                    }
                } else {
                    Text("Loading ..")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.vertical)
            .navigationTitle("Select the Installed UPI Apps to Continue")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    UPIView()
}
