//  GeneratedPhotoView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI

struct GeneratedPhotoView: View {
    @State private var viewModel = GeneratedPhotoViewModel()
    @Environment(\.dismiss) private var dismiss
    let uniqueID: UUID
    let originalImageData: Data?
    let furnitureMarkers: [FurnitureMarker]
    
    init(uniqueID: UUID, originalImageData: Data? = nil, furnitureMarkers: [FurnitureMarker] = []) {
        self.uniqueID = uniqueID
        self.originalImageData = originalImageData
        self.furnitureMarkers = furnitureMarkers
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content takes full screen
            if let result = viewModel.aiResult {
                AIResultDisplayComponent(
                    result: result,
                    originalImageData: originalImageData,
                    furnitureMarkers: furnitureMarkers
                )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            } else if !viewModel.error.isEmpty {
                errorView
                    .padding()
            } else {
                loadingView
                    .padding()
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.primaryColor)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Your Design")
                    .font(.headline)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.fetchResult(for: uniqueID)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading your design...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(viewModel.error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.fetchResult(for: uniqueID)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.primaryColor)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}
