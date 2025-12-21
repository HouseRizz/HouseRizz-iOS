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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Content
                    if let results = viewModel.aiResult, !results.isEmpty {
                        ForEach(results, id: \.self) { result in
                            AIResultDisplayComponent(result: result)
                        }
                    } else if !viewModel.error.isEmpty {
                        errorView
                    } else if viewModel.aiResult?.isEmpty == true {
                        emptyStateView
                    } else {
                        loadingView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
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
        }
        .onAppear {
            let email = authentication.user?.email
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.fetchResult(for: email ?? "none")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.primaryColor)
                    .font(.title2)
                
                Text("Design History")
                    .font(.title2.weight(.bold))
            }
            
            Text("Your previously generated room designs")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading your designs...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 50))
                .foregroundColor(.primaryColor.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No designs yet")
                    .font(.headline)
                
                Text("Start by creating your first AI room design")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text(viewModel.error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                let email = authentication.user?.email
                viewModel.fetchResult(for: email ?? "none")
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
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
