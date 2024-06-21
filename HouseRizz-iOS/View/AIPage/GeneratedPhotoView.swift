//  GeneratedPhotoView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI

struct GeneratedPhotoView: View {
    @State private var viewModel = GeneratedPhotoViewModel()
    let uniqueID: UUID
    
    var body: some View {
        NavigationStack {
            VStack {
                if let result = viewModel.aiResult {
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
                    } else if !viewModel.error.isEmpty {
                        Text(viewModel.error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("No image URL available.")
                    }
                    
                    Spacer()
                } else {
                    Text("No matching result found.")
                        .padding()
                }
            }
            .navigationTitle("Generated Image")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    viewModel.fetchResult(for: uniqueID)
                }
            }
            .padding()
        }
    }
}
