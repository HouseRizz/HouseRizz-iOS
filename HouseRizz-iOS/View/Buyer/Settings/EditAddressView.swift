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
    @State private var initialState: availableCities = .delhi
    @Environment(\.presentationMode) var presentationMode
    var finalAddress: String {
        address1 + " " + address2 + " " + landmark + " " + pincode + " " + city + " " + state
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text("Your Current Address ")
                        .font(.title3)
                        .bold()
                    
                    Text(authentication.user?.address ?? "")
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                
                Text("Edit Your Address")
                    .font(.title3)
                    .bold()
                
                HRTextField(text: $address1, title: "Flat, House no., Building, Company, Apartment")
                HRTextField(text: $address2, title: "Area, Street, Sector, Village")
                HRTextField(text: $landmark, title: "Landmark")
                HStack {
                    HRTextField(text: $city, title: "Town/City")
                    HRTextField(text: $pincode, title: "Pincode")
                }
                
                NavigationLink {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(availableCities.allCases, id: \.self) { city in
                                CityView(city: city.title)
                                    .onTapGesture {
                                        state = city.title
                                        print(city.title)
                                    }
                            }
                        }
                    }
                    .padding()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .frame(maxWidth: .infinity)
                            .frame(height: 59)
                            .foregroundStyle( Color.primaryColor.opacity(0.5))
                        
                        Text("Pick Your State")
                            .bold()
                            .foregroundStyle( .white)
                    }
                }
                
                Divider()
                
                HRCartButton(buttonText: "Save Address") {
                    authentication.updateAddress(finalAddress)
                    presentationMode.wrappedValue.dismiss()
                }
                
            }
            .padding()
            .navigationTitle("Your Address")
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
