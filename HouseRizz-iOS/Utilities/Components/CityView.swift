//
//  CityView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/06/24.
//

import SwiftUI

struct CityView: View {
    let city: String
    
    var body: some View {
        VStack {
            Image(city)
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
            
            Text(city)
                .foregroundStyle(.gray)
                .bold()
        }
    }
}

#Preview {
    CityView(city: "Delhi")
}
