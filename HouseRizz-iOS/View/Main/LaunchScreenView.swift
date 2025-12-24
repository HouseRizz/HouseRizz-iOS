//
//  LaunchScreenView.swift
//  HouseRizz-iOS
//
//  Created for smooth transition during auth check.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            Image("Person")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 40)
        }
    }
}

#Preview {
    LaunchScreenView()
}
