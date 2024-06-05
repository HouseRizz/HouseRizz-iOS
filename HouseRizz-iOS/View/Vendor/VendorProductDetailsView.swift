//
//  CKProductDetailsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI

struct VendorProductDetailsView: View {
    var product: HRProduct
    private var imageUrls: [URL?] {
        [product.imageURL1, product.imageURL2, product.imageURL3]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
            
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(imageUrls.compactMap({ $0 }), id: \.self) { url in
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
                .background(.white)
                .cornerRadius(20)
                .offset(y: -30)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
