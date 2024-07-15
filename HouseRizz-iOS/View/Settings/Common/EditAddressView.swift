//
//  EditAddressView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 10/06/24.
//

import SwiftUI

struct EditAddressView: View {
    @StateObject var authentication = Authentication()
    @State private var viewModel = CityPickerViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var address1: String = ""
    @State private var address2: String = ""
    @State private var landmark: String = ""
    @State private var pincode: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var showStatePickerSheet: Bool = false
    @State private var showAlert: Bool = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var finalAddress: String {
        [address1, address2, landmark, pincode, city, state].filter { !$0.isEmpty }.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentAddressSection
                    editAddressSection
                    statePickerButton
                    saveAddressButton
                }
                .padding()
            }
            .navigationTitle("Your Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
            .sheet(isPresented: $showStatePickerSheet) {
                statePickerView
            }
        }
    }
    
    private var currentAddressSection: some View {
        VStack {
            Text("Your Current Address")
                .font(.title3)
                .bold()
            
            Text(authentication.user?.address ?? "No address set")
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
        }
    }
    
    private var editAddressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
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
        }
    }
    
    private var statePickerButton: some View {
        Button(action: {
            showStatePickerSheet = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 59)
                    .foregroundStyle(Color.primaryColor.opacity(0.5))
                
                Text(state.isEmpty ? "Pick Your State" : state)
                    .bold()
                    .foregroundStyle(.white)
            }
        }
    }
    
    private var statePickerView: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.cities, id: \.id) { city in
                        VStack {
                            if let url = city.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(20)
                            } else {
                                Image(systemName: "building.2")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(20)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(city.name)
                                .foregroundStyle(.gray)
                                .bold()
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .onTapGesture {
                            state = city.name
                            showStatePickerSheet = false
                            showAlert = true
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showStatePickerSheet = false
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\(state) Selected"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var saveAddressButton: some View {
        HRCartButton(buttonText: "Save Address") {
            authentication.updateAddress(finalAddress)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var dismissButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.red)
        }
    }
}

#Preview {
    EditAddressView()
}
