//
//  ProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/04/24.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ProductCategoryView(productCategory: Category.sofa)) {
                    CategoryCard(image: Category.sofa.image, title: Category.sofa.title)
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
