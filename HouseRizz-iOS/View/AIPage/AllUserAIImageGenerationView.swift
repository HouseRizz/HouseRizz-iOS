//
//  AllUserAIImageGenerationView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI

struct AllUserAIImageGenerationView: View {
    @State private var viewModel = AllUserAIImageGenerationViewModel()
    @ObservedObject var authentication: Authentication
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let results = viewModel.aiResult {
                        ForEach(results, id: \.self) { result in
                            AIResultDisplayComponent(result: result)
                        }
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
                    let email = authentication.user?.email
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        viewModel.fetchResult(for: email ?? "none")
                    }
                }
            }
        }
    }
}
