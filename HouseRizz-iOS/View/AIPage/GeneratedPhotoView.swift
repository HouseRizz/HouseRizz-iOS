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
                    AIResultDisplayComponent(result: result)
                } else if !viewModel.error.isEmpty {
                    Text(viewModel.error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("No matching result found.")
                        .padding()
                }
                
                Spacer()
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
