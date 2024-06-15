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
    @State private var editPhoneNumber: Bool = false
    @State private var editablePhoneNumber: String = ""
    @State private var showEditAddress: Bool = false
    @State private var deleteAccount: Bool = false
    @State private var showTerms:Bool = false
    @State private var showPrivacy:Bool = false
    @State private var showHelp:Bool = false
    @State private var showRefund:Bool = false
    
    var body: some View {
        NavigationStack {
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
                            if editPhoneNumber {
                                TextField("Phone Number", text: $editablePhoneNumber, onCommit: {
                                    authentication.updatePhoneNumber(editablePhoneNumber)
                                })
                                .frame(width: 110)
                                .foregroundStyle(.blue)
                            } else {
                                Text(user.phoneNumber ?? "Not Provided")
                                    .foregroundStyle(.blue)
                                    .onTapGesture {
                                        editPhoneNumber.toggle()
                                    }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "house")
                            Text("Address")
                            Spacer()
                            Text((user.address ?? "Not Provided").prefix(15) + "...")
                                .foregroundStyle(.blue)
                                .onTapGesture {
                                    showEditAddress.toggle()
                                }
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
                    
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Delete Account")
                    }
                    .foregroundStyle(.red)
                    .onTapGesture {
                        deleteAccount.toggle()
                    }
                }  header: {
                    Text("Leave")
                }
                
                Section {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Help Center")
                    }
                    .onTapGesture {
                        showHelp = true
                    }
                    HStack {
                        Image(systemName: "book.closed")
                        Text("Terms of Use")
                    }
                    .onTapGesture {
                        showTerms = true
                    }
                    HStack {
                        Image(systemName: "lock")
                        Text("Privacy Policy")
                    }
                    .onTapGesture {
                        showPrivacy = true
                    }
                    HStack {
                        Image(systemName: "archivebox")
                        Text("Refund Policy")
                    }
                    .onTapGesture {
                        showRefund = true
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showEditAddress, content: {
                EditAddressView()
            })
            .sheet(isPresented: $showHelp, content: {
                HelpView()
            })
            .sheet(isPresented: $showTerms, content: {
                TermsView()
            })
            .sheet(isPresented: $showPrivacy, content: {
                PrivacyView()
            })
            .sheet(isPresented: $showRefund, content: {
                RefundView()
            })
            .alert(isPresented: $deleteAccount) {
                Alert(title: Text("Delete Account"),
                      message: Text("This action will delete your account information, orders, and any other information"),
                      primaryButton: .destructive(Text("Delete"), action: {
                    authentication.delete()
                }),
                      secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }
    }
}

#Preview {
    SettingsView()
}
