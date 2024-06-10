//
//  EditAddressView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 10/06/24.
//

import SwiftUI

struct EditAddressView: View {
    @StateObject var authentication = Authentication()
    @State private var address1: String = ""
    @State private var address2: String = ""
    @State private var landmark: String = ""
    @State private var pincode: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                ScrollView {
                    HRTextField(text: $address1, title: "Flat, House no., Building, Company, Apartment")
                    HRTextField(text: $address2, title: "Area, Street, Sector, Village")
                    HRTextField(text: $landmark, title: "Landmark")
                    
                    HStack {
                        HRTextField(text: $pincode, title: "Pincode")
                        HRTextField(text: $city, title: "Town/City")
                    }
                    
                    HStack {
                        Text("State")
                        
                        Spacer()
                        
                        Picker("State", selection: $state) {
                            ForEach(availableCities.allCases, id: \.self) {
                                Text($0.title)
                            }
                        }
                    }
                }
                
                Divider()
                
                HRCartButton(buttonText: "Save Address") {
                    authentication.updateAddress("\(address1+address2+landmark+pincode+city+state)")
                }
            }
            .padding()
            .navigationTitle("Edit Address")
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
        }
    }
}

#Preview {
    EditAddressView()
}
