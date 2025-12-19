//
//  CKProductCardView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI

struct InventoryProductCardView: View {
    var product: HRProduct
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                if let url = product.imageURL1Value {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 175, height: 160)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.gray, lineWidth: 0.5)
                                )
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 175, height: 160)
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                                .frame(width: 175, height: 160)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text(product.name)
                    .font(.subheadline)
                    .padding(.vertical, 1)
                
                Text(product.price?.formattedCurrency() ?? "")
                    .font(.caption2)
            }
        }
        .frame(width: 185, height: 260)
        .cornerRadius(15)
    }
}
