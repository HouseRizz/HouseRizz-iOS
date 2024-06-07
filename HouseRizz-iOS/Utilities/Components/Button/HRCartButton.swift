//
//  HRCartButton.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 07/06/24.
//

import SwiftUI

struct HRCartButton: View {
    var buttonText: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryColor)
                .cornerRadius(10)
        }
        .padding(.horizontal,5)
    }
}
