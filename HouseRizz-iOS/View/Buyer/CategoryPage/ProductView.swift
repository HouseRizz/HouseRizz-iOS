//
//  ProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/04/24.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Category.allCases, id: \.self) { category in
                            NavigationLink(destination: ProductCategoryView(productCategory: category)) {
                                CategoryCard(image: category.image, title: category.title)
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
    ProductView()
        .environmentObject(CartViewModel())
}
