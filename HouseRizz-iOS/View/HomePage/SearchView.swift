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
    @State private var columns = [GridItem]()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    LazyVGrid(columns: columns, spacing: 20) {
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
        .onAppear {
            setColumns(for: UIScreen.main.bounds.width)
        }
        .onChange(of: UIScreen.main.bounds.width) { newWidth in
            setColumns(for: newWidth)
        }
    }
    
    private func setColumns(for width: CGFloat) {
        let minItemWidth: CGFloat = 160
        let spacing: CGFloat = 20
        let availableWidth = width - (2 * spacing) // Subtracting horizontal padding
        
        if availableWidth >= (minItemWidth * 2 + spacing) {
            // If we can fit two columns, use two flexible columns
            columns = [
                GridItem(.flexible(minimum: minItemWidth), spacing: spacing),
                GridItem(.flexible(minimum: minItemWidth), spacing: spacing)
            ]
        } else {
            // If we can't fit two columns, use one flexible column
            columns = [
                GridItem(.flexible(minimum: minItemWidth), spacing: spacing)
            ]
        }
    }
}
