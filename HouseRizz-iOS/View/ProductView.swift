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
                NavigationLink(destination: ProductCategoryView()) {
                    ZStack {
                        Color.orange.opacity(0.2)
                        
                        HStack {
                            Text("All Products")
                                .bold()
                            
                            Image("cat")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }

                    }
                    .frame(width: 300, height: 100)
                    .cornerRadius(20)
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
