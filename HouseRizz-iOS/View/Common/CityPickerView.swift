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
    @State private var viewModel = CityPickerViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.cities, id: \.id) { city in
                        VStack {
                            if let url = city.imageURLValue {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.gray, lineWidth: 0.5)
                                            )
                                    case .failure(_):
                                        Image(systemName: "photo")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            Text(city.name)
                                .bold()
                                .font(.subheadline)
                                .padding(.vertical, 1)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .onTapGesture {
                            searchViewModel.selectedCity = city.name
                            searchViewModel.showAlert = true
                        }
                    }
                }
                .padding()
            }
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
            .alert(isPresented: $searchViewModel.showAlert) {
                Alert(
                    title: Text("\(searchViewModel.selectedCity) Selected"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.fetchCities()
            }
            .refreshable {
                viewModel.fetchCities()
            }
        }
    }
}
