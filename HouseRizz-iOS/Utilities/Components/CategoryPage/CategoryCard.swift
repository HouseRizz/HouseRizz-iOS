//
//  CategoryCard.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 16/04/24.
//

import SwiftUI

struct CategoryCard: View {
    var image: String
    var title: String

    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .frame(width: 100,height: 100)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray, lineWidth: 0.5)
                )
            VStack {
                Text(title)
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

#Preview {
    CategoryCard(image: Category.sofa.image, title: Category.sofa.title)
}
