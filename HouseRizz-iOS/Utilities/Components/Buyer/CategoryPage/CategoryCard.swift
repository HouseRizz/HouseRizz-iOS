//
//  CategoryCard.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 16/04/24.
//

import SwiftUI

struct CategoryCard: View {
    var category: HRProductCategory

    var body: some View {
        VStack {
            if let url = category.imageURLValue {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray, lineWidth: 0.5)
                            )
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack {
                Text(category.name)
                    .bold()
                    .font(.subheadline)
                    .padding(.vertical, 1)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
    }
}
