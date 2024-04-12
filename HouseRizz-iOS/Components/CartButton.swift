//
//  CartButton.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/04/24.
//

import SwiftUI

struct CartButton: View {
    var numberOfProducts: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "bag.fill")
                .foregroundStyle(.black)
                .padding(5)
            
            if numberOfProducts > 0 {
                Text("\(numberOfProducts)")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .frame(width: 15, height: 15)
                    .background(.purple)
                    .cornerRadius(50)
            }
        }
    }
}

#Preview {
    CartButton(numberOfProducts: 1)
}
