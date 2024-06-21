//
//  AIResultDisplayComponent.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI

struct AIResultDisplayComponent: View {
    let result: HRAIImageResult
    
    var body: some View {
        VStack {
            HStack {
                Text(result.vibe)
                Text(result.type)
            }
            .font(.title)
            .bold()
            
            if let urlString = result.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                        ShareLink("Export", item: url)
                            .padding(32)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .foregroundStyle(.red)
                            .padding()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("No image URL available.")
            }
        }
    }
}
