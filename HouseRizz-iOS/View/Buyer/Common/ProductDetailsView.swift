//
//  ProductDetailsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct ProductDetailsView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var quantity: Int = 1
    var product: HRProduct
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topTrailing) {
                    if let url = product.imageURL1, let data = try? Data(contentsOf: url), let image = UIImage(data: data){
                        Image(uiImage: image)
                            .resizable()
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 300)
                    }
                    
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.top, 65)
                        .padding(.trailing, 20)
                        .foregroundStyle(Color.primaryColor)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.name)
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Text(((product.price ?? 0) * Double(quantity)).formattedCurrency())
                            .font(.caption2)
                            .foregroundStyle(.black)
                    }
                    .padding(.vertical)
                    
                    HStack {
                        HStack(spacing: 10) {
                            ForEach(0..<5) { index in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.yellow)
                            }
                            Text("(4.5)")
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical)
                        
                        Spacer()
                        
                        HStack {
                            Button {
                                if quantity > 1 {
                                    quantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.square")
                                    .foregroundStyle(Color.primaryColor.opacity(0.5))
                            }
                            
                            Text("\(quantity)")
                                .font(.title2)
                            
                            Button {
                                quantity += 1
                            } label: {
                                Image(systemName: "plus.square.fill")
                                    .foregroundStyle(Color.primaryColor.opacity(0.5))
                            }
                        }
                    }
                    
                    Text("Description")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text(product.description ?? "")
                    
                    Spacer()
                    

                    
                    Button(action: {
                        cartViewModel.addToCart(product: product, quantity: quantity)
                    }) {
                        Text("Add to Cart")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryColor)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
                .padding()
                .cornerRadius(20)
                .offset(y: -30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .environmentObject(cartViewModel)
    }
}

struct ColorDotView: View {
    var color: Color
    
    var body: some View {
        color
            .frame(width: 25, height: 25)
            .clipShape(Circle())
    }
}
