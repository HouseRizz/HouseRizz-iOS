//
//  ManageCitiesView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/07/24.
//

import SwiftUI

struct ManageCitiesView: View {
    @State private var viewModel = ManageCitiesViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.cities.indices, id: \.self) { index in
                            let city = viewModel.cities[index]
                            VStack {
                                if let url = city.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.gray, lineWidth: 0.5)
                                        )
                                }
                                
                                VStack {
                                    Text(city.name)
                                        .bold()
                                        .font(.subheadline)
                                        .padding(.vertical, 1)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                viewModel.fetchCities()
            }
            .refreshable {
                viewModel.fetchCities()
            }
            .navigationTitle("Cities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddCitiesView()
                            .toolbarRole(.editor)
                    } label: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .bold()
                    }
                }
            }
        }
    }
}
#Preview {
    ManageCitiesView()
}
