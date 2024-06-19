//
//  HomeView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var selectedProduct: HRProduct?
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var searchViewModel: SearchViewModel
    var column = [GridItem(.adaptive(minimum: 160), spacing: 20)]

    var body: some View {
        NavigationStack {
            VStack {
                Image("TextHouseRizz")
                    .resizable()
                    .frame(width: 150, height: 40)
                
                SearchBarView()
                
                ScrollView {
                    VStack {
                        ImageSliderView(slides: ["coming1","coming2"])
                        
                        ImageSliderView(slides: ["greensofa","graysofa"])

                        Text("Featured Products")
                            .font(.title3.bold())

                        LazyVGrid(columns: column) {
                            ForEach(viewModel.products.indices, id: \.self) { index in
                                ProductCardView(product: viewModel.products[index])
                                    .environmentObject(cartViewModel)
                                    .onTapGesture {
                                        selectedProduct = viewModel.products[index]
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .environmentObject(cartViewModel)
            .sheet(item: $selectedProduct) { product in
                ProductDetailsView(product: product)
                    .environmentObject(cartViewModel)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CartViewModel())
}
