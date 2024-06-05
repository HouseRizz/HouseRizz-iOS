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

    var column = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    var productCategory: Category

    var body: some View {
        NavigationView {
            VStack {
                SearchView()
                    .padding(.top, 10)
                
                /*
                 LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                     ForEach(viewModel.products.indices, id: \.self) { index in
                         ProductCardView(product: viewModel.products[index])
                             .environmentObject(cartViewModel)
                             .onTapGesture {
                                 selectedProduct = viewModel.products[index]
                             }
                     }
                 }
                 .filter { $0.category == productCategory }
                 */

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
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: CartView().environmentObject(cartViewModel)) {
                    CartButton(numberOfProducts: cartViewModel.products.count)
                }
            }
        }
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
