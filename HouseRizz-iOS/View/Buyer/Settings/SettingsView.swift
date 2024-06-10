//
//  SettingsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var authentication = Authentication()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var showVendorInventory: Bool = false
    @State private var showVendorOrders: Bool = false
    @State private var showBuyerOrders: Bool = false
    @State private var showEditPhoneNumber: Bool = false
    @State private var editablePhoneNumber: String = ""
    
    var body: some View {
        NavigationView {
            List {
                if let user = authentication.user {
                    Section {
                        HStack {
                            Image(systemName: "person")
                            Text("Email")
                            Spacer()
                            Text(user.name)
                                .foregroundStyle(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "envelope")
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundStyle(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "phone")
                            Text("Phone Number")
                            Spacer()
                            if showEditPhoneNumber {
                                TextField("Phone Number", text: $editablePhoneNumber, onCommit: {
                                    authentication.updatePhoneNumber(editablePhoneNumber)
                                })
                                .frame(width: 110)
                                .foregroundStyle(.blue)
                            } else {
                                Text(user.phoneNumber ?? "Not Provided")
                                    .foregroundStyle(.blue)
                                    .onTapGesture {
                                        showEditPhoneNumber.toggle()
                                    }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "house")
                            Text("Address")
                            Spacer()
                            Text(user.address ?? "Not Provided")
                                .foregroundStyle(.blue)
                        }
                    } header: {
                        Text("Account")
                    }
                } else {
                    Text("Loading Profile ..")
                }
                
                
                if authentication.user?.userType == "vendor" {
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
                        authentication.signOut()
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
                authentication.fetchUser()
                if let phoneNumber = authentication.user?.phoneNumber {
                    editablePhoneNumber = phoneNumber
                }
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
