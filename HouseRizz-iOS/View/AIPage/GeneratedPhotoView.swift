//  GeneratedPhotoView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI

struct GeneratedPhotoView: View {
//    @ObservedObject var viewModel: AIImageGenerationViewModel
    
    var body: some View {
        VStack {
//            if let prediction = viewModel.prediction, let url = prediction.output {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 200)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                    case .failure:
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 200)
//                            .foregroundStyle(.red)
//                            .padding()
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                Text("No image generated")
//                    .foregroundStyle(.gray)
//                    .padding()
//            }
        }
        .navigationTitle("Generated Image")
        .navigationBarTitleDisplayMode(.inline)
    }
}
