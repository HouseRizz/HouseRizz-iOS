//
//  ProductCardView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct ProductCardView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.colorScheme) var colorScheme
    var product: HRProduct
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                if let url = product.imageURL1, let data = try? Data(contentsOf: url), let image = UIImage(data: data){
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 175,height: 160)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 0.5)
                            )
                }
                
                VStack {
                    Text(product.name)
                        .font(.subheadline)
                        .padding(.vertical, 1)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                    
                Text((product.price ?? 0).formattedCurrency())
                    .font(.caption2)
            }
            
            Button{
                cartViewModel.addToCart(product: product)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 25,height: 25)
                    .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .padding(5)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.gray, lineWidth: 0.5)
        )
        .padding(5)
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
