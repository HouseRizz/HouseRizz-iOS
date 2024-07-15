//
//  SettingsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import SwiftUI

enum SettingsViewState: Identifiable {
    case vendorInventory
    case vendorOrders
    case buyerOrders
    case editAddress
    case terms
    case privacy
    case refund
    case login
    case entireInventory
    case entireOrders
    case notificationManager
    case categoriesManager
    case appBannerManager
    case api
    case vibe
    case city
    
    var id: Self { self }
}

struct SettingsView: View {
    @StateObject var authentication = Authentication()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @State private var activeState: SettingsViewState?
    @State private var editPhoneNumber: Bool = false
    @State private var editablePhoneNumber: String = ""
    @State private var deleteAccount: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if let user = authentication.user {
                    Section {
                        HStack {
                            Image(systemName: "person")
                            Text("Name")
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
                                    activeState = .editAddress
                                }
                        }
                    } header: {
                        Text("Account")
                    }
                } else {
                    Text("Loading Profile ..")
                }
                
                if authentication.user?.name == "Anonymous User" {
                    Section {
                        HStack {
                            Image(systemName: "person.circle")
                            Text("Log in")
                        }
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            authentication.signOut()
                        }
                    }  header: {
                        Text("Join")
                    }
                }
                
                if authentication.user?.userType == "vendor" {
                    Section {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Manage Inventory")
                        }
                        .onTapGesture {
                            activeState = .vendorInventory
                        }
                        
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Manage Orders")
                        }
                        .onTapGesture {
                            activeState = .vendorOrders
                        }
                    } header: {
                        Text("Vendor")
                    }
                } else if authentication.user?.userType == "admin" {
                    Section {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Manage Entire App Inventory")
                        }
                        .onTapGesture {
                            activeState = .entireInventory
                        }
                        
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Manage Entire App Orders")
                        }
                        .onTapGesture {
                            activeState = .entireOrders
                        }
                        
                        HStack {
                            Image(systemName: "bell")
                            Text("Manage Entire App Notifications")
                        }
                        .onTapGesture {
                            activeState = .notificationManager
                        }
                        
                        HStack {
                            Image(systemName: "tray.2")
                            Text("Product Categories")
                        }
                        .onTapGesture {
                            activeState = .categoriesManager
                        }
                        
                        HStack {
                            Image(systemName: "banknote")
                            Text("App Banners")
                        }
                        .onTapGesture {
                            activeState = .appBannerManager
                        }
                        HStack {
                            Image(systemName: "lock")
                            Text("Manage APIs")
                        }
                        .onTapGesture {
                            activeState = .api
                        }
                        HStack {
                            Image(systemName: "scribble")
                            Text("Manage Vibe")
                        }
                        .onTapGesture {
                            activeState = .vibe
                        }
                        HStack {
                            Image(systemName: "location")
                            Text("Manage Cities")
                        }
                        .onTapGesture {
                            activeState = .city
                        }
                    } header: {
                        Text("Admin")
                    }
                } else {
                    Section {
                        HStack {
                            Image(systemName: "archivebox")
                            Text("Order History")
                        }
                        .onTapGesture {
                            activeState = .buyerOrders
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
                        Image(systemName: "book.closed")
                        Text("Terms of Use")
                    }
                    .onTapGesture {
                        activeState = .terms
                    }
                    HStack {
                        Image(systemName: "lock")
                        Text("Privacy Policy")
                    }
                    .onTapGesture {
                        activeState = .privacy
                    }
                    HStack {
                        Image(systemName: "archivebox")
                        Text("Refund Policy")
                    }
                    .onTapGesture {
                        activeState = .refund
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
            .sheet(item: $activeState) { state in
                switch state {
                case .vendorInventory:
                    VendorInventoryView()
                case .vendorOrders:
                    VendorOrdersView()
                case .buyerOrders:
                    OrderHistoryListView()
                case .editAddress:
                    EditAddressView()
                case .terms:
                    TermsView()
                case .privacy:
                    PrivacyView()
                case .refund:
                    RefundView()
                case .login:
                    AuthenticationView()
                case .entireInventory:
                    AdminInventoryView()
                case .entireOrders:
                    AdminOrdersView()
                case .categoriesManager:
                    ManageProductCategoriesView()
                case .appBannerManager:
                    ManageAddBannerView()
                case .api:
                    APIView()
                case .vibe:
                    ManageAIVibeView()
                case .city:
                    ManageCitiesView()
                case .notificationManager:
                    Text("Notification Manager View")
                }
            }
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
