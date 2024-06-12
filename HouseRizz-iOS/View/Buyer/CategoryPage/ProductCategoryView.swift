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
    @StateObject private var searchViewModel = SearchViewModel()

    var column = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    var productCategory: Category

    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(searchViewModel: searchViewModel)
                    .padding(.top, 10)

                ScrollView {
                    LazyVGrid(columns: column) {
                        ForEach(viewModel.products.filter { $0.category == productCategory.title }, id: \.self) { product in
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
        .navigationTitle(productCategory.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { product in
            ProductDetailsView(product: product)
                .environmentObject(cartViewModel)
        }
    }
}

#Preview {
    ProductCategoryView(productCategory: Category.sofa)
        .environmentObject(CartViewModel())
}
