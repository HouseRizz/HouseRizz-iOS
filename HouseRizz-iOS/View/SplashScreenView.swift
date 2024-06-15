//
//  SplashScreenView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/06/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false
    
    var body: some View {
        ZStack{
            if self.isActive {
                MainView()
            } else {
                Color.primaryColor.edgesIgnoringSafeArea(.all)
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }

}

#Preview {
    SplashScreenView()
}
