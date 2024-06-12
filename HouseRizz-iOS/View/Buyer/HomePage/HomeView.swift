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
    @StateObject private var searchViewModel = SearchViewModel() 

    var body: some View {
        NavigationStack {
            VStack {
                Image("TextLogo")
                    .resizable()
                    .frame(width: 150, height: 40)
                
                SearchBarView(searchViewModel: searchViewModel)
                
                ScrollView {
                    VStack {
                        ImageSliderView()

                        Text("Trending Near You")
                            .font(.title3.bold())

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
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
