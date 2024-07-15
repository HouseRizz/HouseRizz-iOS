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
    @State private var columns = [GridItem]()

    var groupedAdds: [Int: [HRAddBanner]] {
        Dictionary(grouping: viewModel.adds, by: { $0.sliderNumber })
    }

    var body: some View {
        NavigationStack {
            VStack {
                Image("TextHouseRizz")
                    .resizable()
                    .frame(width: 150, height: 40)
                
                SearchBarView()
                
                ScrollView {
                    VStack {
                        ForEach(groupedAdds.keys.sorted(), id: \.self) { sliderNumber in
                            if let adds = groupedAdds[sliderNumber] {
                                ImageSliderView(slides: adds)
                            }
                        }

                        Text("Featured Products")
                            .font(.title3.bold())

                        LazyVGrid(columns: columns, spacing: 20) {
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
            .onAppear {
                setColumns(for: UIScreen.main.bounds.width)
            }
            .onChange(of: UIScreen.main.bounds.width) { newWidth in
                setColumns(for: newWidth)
            }
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

#Preview {
    HomeView()
        .environmentObject(CartViewModel())
}
