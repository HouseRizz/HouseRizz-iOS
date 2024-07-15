//
//  ProductCategoryView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 16/04/24.
//

import SwiftUI

struct ProductCategoryView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedProduct: HRProduct?
    @StateObject private var viewModel = ProductCategoryViewModel()
    @State private var columns = [GridItem]()
    var productCategory: HRProductCategory

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.products.filter { $0.category == productCategory.name }, id: \.self) { product in
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
        }
        .navigationTitle(productCategory.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { product in
            ProductDetailsView(product: product)
                .environmentObject(cartViewModel)
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: CartView().environmentObject(cartViewModel)) {
                    CartButton(numberOfProducts: cartViewModel.products.count)
                }
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
