//
//  CityPickerView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/06/24.
//

import SwiftUI

struct CityPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var searchViewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(availableCities.allCases, id: \.self) { city in
                        CityView(city: city.title)
                            .onTapGesture {
                                searchViewModel.selectedCity = city.title
                                searchViewModel.showAlert = true
                            }
                            .alert(isPresented: $searchViewModel.showAlert) {
                                Alert(
                                    title: Text("\(searchViewModel.selectedCity) Selected"),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                    }
                }
            }
            .padding()
            .navigationTitle("Select Your City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}
