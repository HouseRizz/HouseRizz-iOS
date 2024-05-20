//
//  HRTextField.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI

struct HRTextField: View {
    @Binding var text: String
    var title: String
    var axis: Axis = .horizontal
    
    var body: some View {

        VStack(alignment: .leading) {
            if !text.isEmpty {
                Text(title)
                    .foregroundStyle(.gray)
            }
            TextField(title, text: $text, axis: axis)
                .lineLimit(2...15)
                .font(.system(.title3, design: .rounded))
                .padding(15)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1)
                )
        }
    }
}
