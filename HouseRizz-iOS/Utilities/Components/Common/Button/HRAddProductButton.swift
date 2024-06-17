//
//  HRAddProductButton.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 02/06/24.
//

import SwiftUI

struct HRAddProductButton: View {
    var buttonText: String
    var background: Color
    var textColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(background)
                
                Text(buttonText)
                    .bold()
                    .foregroundStyle(textColor)
            }
        }
        .padding(.horizontal,5)
    }
}
