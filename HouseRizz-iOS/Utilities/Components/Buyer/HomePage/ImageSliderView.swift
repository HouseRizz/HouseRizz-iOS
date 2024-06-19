//
//  ImageSliderView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import SwiftUI

struct ImageSliderView: View {
    @State private var currentIndex = 0
    var slides: [HRAddBanner]
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack(alignment: .trailing) {
                if let url = slides[currentIndex].imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data){
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: .none, height: 180)
                        .scaledToFit()
                        .cornerRadius(15)
                }
            }
            
            HStack {
                ForEach(0..<slides.count, id: \.self){index in
                    Circle()
                        .fill(self.currentIndex == index ? Color.blue: Color.black)
                        .frame(width: 10, height: 10)
                }
            }
            .padding()
        }
        .padding()
        .onAppear{
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true){ timer in
                if self.currentIndex + 1 == self.slides.count{
                    self.currentIndex = 0
                } else {
                    self.currentIndex += 1
                }
            }
        }
    }
}
