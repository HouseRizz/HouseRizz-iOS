//
//  CKProductDetailsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI

struct InventoryProductDetailView: View {
    var product: HRProduct
    private var imageUrls: [URL?] {
        [product.imageURL1Value, product.imageURL2Value, product.imageURL3Value]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(imageUrls.compactMap({ $0 }), id: \.self) { url in
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
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.title2.bold())
                            
                            Text(product.category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Text(product.price?.formattedCurrency() ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    Text("Description")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text(product.description ?? "")
                    
                    Spacer()
                }
                .padding()
                .cornerRadius(20)
                .offset(y: -30)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
