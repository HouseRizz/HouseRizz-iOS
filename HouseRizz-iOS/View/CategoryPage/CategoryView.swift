//
//  ProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/04/24.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())]
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.categories.indices, id: \.self) { category in
                            NavigationLink(destination: ProductCategoryView(productCategory: viewModel.categories[category])) {
                                CategoryCard(category: viewModel.categories[category])
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("All Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: CartView().environmentObject(cartViewModel)) {
                        CartButton(numberOfProducts: cartViewModel.products.count)
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryView()
        .environmentObject(CartViewModel())
}
