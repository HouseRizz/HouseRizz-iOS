//
//  ProductView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct ProductView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        AppBar
                        
                        SearchView()
                        
                        ImageSliderView()
                        
                        HStack {
                            Text("New Arrivals")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Image(systemName: "circle.grid.2x2.fill")
                                .foregroundStyle(.purple.opacity(0.2))
                        }
                        .padding()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(productList, id: \.id) {product in
                                    NavigationLink{
                                        ProductDetailsView(product: product)
                                    } label: {
                                        ProductCardView(product: product)
                                            .environmentObject(cartViewModel)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        Spacer()
                    }
                }
            }
        }
        .environmentObject(cartViewModel)
    }
    
    @ViewBuilder
    var AppBar: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location.north.fill")
                    .resizable()
                    .frame(width: 20,height: 20)
                    .padding(.trailing)
                
                Text("Delhi, India")
                    .font(.title2)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                NavigationLink(destination: CartView().environmentObject(cartViewModel)) {
                    CartButton(numberOfProducts: cartViewModel.products.count)
                }
            }
            
            Text("Get The Most Realistic")
                .font(.largeTitle .bold())
            
            Text("Furniture Experience")
                .font(.largeTitle .bold())
                .foregroundStyle(.purple.opacity(0.4))
        }
        .padding()
    }
}

#Preview {
    ProductView()
        .environmentObject(CartViewModel())
}
