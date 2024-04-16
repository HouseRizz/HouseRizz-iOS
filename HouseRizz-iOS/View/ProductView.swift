//
//  ProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/04/24.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Category.allCases, id: \.self) { category in
                            NavigationLink(destination: ProductCategoryView(productCategory: category)) {
                                CategoryCard(image: category.image, title: category.title)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Categories")
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
