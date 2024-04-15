//
//  HomeView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct HomeView: View {
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
                        
                        HStack {
                            Text("Rizz Up ")
                                .font(.title .bold())
                            + Text("Your House!")
                                .font(.title .bold())
                                .foregroundStyle(.orange)
                            Spacer()
                            Image("cat")
                                .resizable()
                                .frame(width: 100,height: 80)
                        }
                        .padding(.horizontal)
                        
                        ImageSliderView()
                        
                        Text("Trending Near You")
                            .font(.title2 .bold())
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(productList, id: \.id) { product in
                                NavigationLink {
                                    ProductDetailsView(product: product)
                                } label: {
                                    ProductCardView(product: product)
                                        .environmentObject(cartViewModel)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .environmentObject(cartViewModel)
    }
    
    @ViewBuilder
    var AppBar: some View {
        VStack {
            HStack{
                Image("Person")
                    .resizable()
                    .frame(width: 40,height: 40)
                
                VStack(alignment: .leading) {
                    Text("Delivery Available")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Image(systemName: "location")
                        Text("Rohini, Delhi 110085")
                    }
                    .font(.caption2)
                    .foregroundStyle(.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: CartView().environmentObject(cartViewModel)) {
                    CartButton(numberOfProducts: cartViewModel.products.count)
                }
            }
            
            
        }
        .padding()
    }
}

#Preview {
    HomeView()
        .environmentObject(CartViewModel())
}
