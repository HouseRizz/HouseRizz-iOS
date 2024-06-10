//
//  SettingsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var auth = Authentication()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var showVendorInventory: Bool = false
    @State private var showVendorOrders: Bool = false
    @State private var showBuyerOrders: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Email")
                        Spacer()
                        if let user = auth.user {
                            Text(user.email)
                                .foregroundStyle(.gray)
                        } else {
                            Text("Loading Profile ..")
                                .foregroundStyle(.gray)
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                if auth.user?.userType == "vendor" {
                    Section {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Manage Inventory")
                        }
                        .onTapGesture {
                            showVendorInventory.toggle()
                        }
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Manage Orders")
                        }
                        .onTapGesture {
                            showVendorOrders.toggle()
                        }
                    } header: {
                        Text("Vendor")
                    }
                } else {
                    Section {
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Order History")
                        }
                        .onTapGesture {
                            showBuyerOrders.toggle()
                        }
                    } header: {
                        Text("Orders")
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign out")
                    }
                    .foregroundStyle(.red)
                    .onTapGesture {
                        auth.signOut()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                    
                }
            }
            .onAppear {
                auth.fetchUser()
            }
            .sheet(isPresented: $showVendorInventory, content: {
                ProductInventoryView()
            })
            .sheet(isPresented: $showVendorOrders, content: {
                ManageOrdersView()
            })
            .sheet(isPresented: $showBuyerOrders, content: {
                OrderHistoryListView()
            })
        }
    }
}

#Preview {
    SettingsView()
}
