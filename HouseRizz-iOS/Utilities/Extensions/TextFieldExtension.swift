//
//  TextFieldExtension.swift
//  InventoryManagement
//
//  Created by Krish Mittal on 24/05/24.
//

import SwiftUI

struct TextFieldStyle: ViewModifier {
    func body(content: Content) -> some View{
        content
            .font(.system(.title3, design: .rounded))
            .padding(15)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 1)
            )
    }
}

extension TextField {
    func customTextFieldStyle() -> some View {
        modifier(TextFieldStyle())
    }
}
