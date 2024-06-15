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
    private var imageUrls: [URL?] {
        [product.imageURL1, product.imageURL2, product.imageURL3]
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        let nonEmptyImageUrls = imageUrls.compactMap { $0 }
                        if nonEmptyImageUrls.count > 1 {
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(nonEmptyImageUrls, id: \.self) { url in
                                        if let data = try? Data(contentsOf: url),
                                           let image = UIImage(data: data) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .ignoresSafeArea(edges: .top)
                                                .frame(width: 320, height: 300)
                                        }
                                    }
                                }
                            }
                        } else if let url = nonEmptyImageUrls.first {
                            if let data = try? Data(contentsOf: url),
                               let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .ignoresSafeArea(edges: .top)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                            }
                        }
                        
                        //                        Image(systemName: "heart.fill")
                        //                            .resizable()
                        //                            .frame(width: 25, height: 25)
                        //                            .padding(.top, 65)
                        //                            .padding(.trailing, 20)
                        //                            .foregroundStyle(Color.primaryColor)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(product.category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                        
                        Text(product.name)
                            .font(.title2.bold())
                        
                        HStack {
                            Text(((product.price ?? 0) * Double(quantity)).formattedCurrency())
                                .font(.title3)
                                .fontWeight(.semibold)
                            
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
                        .padding(.vertical, 10)
                        
                        Text("Description")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text(product.description ?? "")
                        
                        
                    }
                    .padding()
                    .padding(.top, 20)
                    .cornerRadius(20)
                    .offset(y: -30)
                }
            }
            
            Divider()
            
            HRCartButton(buttonText: "Add to Cart") {
                cartViewModel.addToCart(product: product, quantity: quantity)
            }
            .padding()
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
