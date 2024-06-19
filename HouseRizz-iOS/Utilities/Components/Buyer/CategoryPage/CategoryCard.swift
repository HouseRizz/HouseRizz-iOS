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
            if let url = category.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data){
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100,height: 100)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray, lineWidth: 0.5)
                    )
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
