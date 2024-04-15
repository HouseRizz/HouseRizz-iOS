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
                    Image(product.image)
                        .resizable()
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 300)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.top, 65)
                        .padding(.trailing, 20)
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.name)
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Text("₹\(product.price * quantity)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
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
                                    .foregroundStyle(.orange.opacity(0.5))
                            }
                            
                            Text("\(quantity)")
                                .font(.title2)
                            
                            Button {
                                quantity += 1
                            } label: {
                                Image(systemName: "plus.square.fill")
                                    .foregroundStyle(.orange.opacity(0.5))
                            }
                        }
                    }
                    
                    Text("Description")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text(product.description)
                    
                    Spacer()
                    
                    HStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Size")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                Text("Height: \(product.height)")
                                    .opacity(0.5)
                                
                                Text("Width: \(product.width)")
                                    .opacity(0.5)
                                
                                Text("Diameter: \(product.diameter)")
                                    .opacity(0.5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Colors")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    ColorDotView(color: .blue)
                                    ColorDotView(color: .black)
                                    ColorDotView(color: .gray)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.vertical)
                    }
                    
                    Button(action: {
                        cartViewModel.addToCart(product: product, quantity: quantity)
                    }) {
                        Text("Add to Cart")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.orange)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
                .padding()
                .background(.white)
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

#Preview {
    ProductDetailsView(product: productList[2])
        .environmentObject(CartViewModel())
}
