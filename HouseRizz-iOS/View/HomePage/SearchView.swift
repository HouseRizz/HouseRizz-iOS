//
//  SearchView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/06/24.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedProduct: HRProduct?
    var column = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    LazyVGrid(columns: column) {
                        ForEach(viewModel.filteredProducts, id: \.self) { product in
                            ProductCardView(product: product)
                                .environmentObject(cartViewModel)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                        }
                    }
                    .padding()
                }
            }
            .refreshable {
                viewModel.fetchItems()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    HStack {
                        HStack {
                            TextField("Search For Your Products", text: $viewModel.search)
                                .padding()
                            
                            Image(systemName: "magnifyingglass")
                                .padding(.trailing)
                            
                        }
                        .background(Color.primaryColor.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
            })
            .environmentObject(cartViewModel)
            .sheet(item: $selectedProduct) { product in
                ProductDetailsView(product: product)
                    .environmentObject(cartViewModel)
            }
        }
    }
}
