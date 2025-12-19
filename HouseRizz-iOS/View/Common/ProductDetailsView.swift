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
        [product.imageURL1Value, product.imageURL2Value, product.imageURL3Value]
    }
    @State private var showAlert: Bool = false
    @State private var showCartView: Bool = false
    
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
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .ignoresSafeArea(edges: .top)
                                                    .frame(width: 320, height: 300)
                                            case .failure(_):
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .ignoresSafeArea(edges: .top)
                                                    .frame(width: 320, height: 300)
                                                    .foregroundColor(.gray)
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 320, height: 300)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                        } else if let url = nonEmptyImageUrls.first {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .ignoresSafeArea(edges: .top)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 300)
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .ignoresSafeArea(edges: .top)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 300)
                                        .foregroundColor(.gray)
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 300)
                                @unknown default:
                                    EmptyView()
                                }
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
                showAlert.toggle()
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
        .environmentObject(cartViewModel)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Product Added to Cart"),
                  primaryButton: .cancel(Text("Ok")),
                  secondaryButton: .default(Text("Go To Cart"), action: {
                    showCartView = true
                  }))
        }
        .sheet(isPresented: $showCartView) {
            NavigationView {
                CartView()
            }
        }
        
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
