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
            Text(title)
                .bold()
                .font(.subheadline)
        }
    }
}

#Preview {
    CategoryCard(image: Category.sofa.image, title: Category.sofa.title)
}
