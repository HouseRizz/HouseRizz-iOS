//
//  AIResultDisplayComponent.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI

struct AIResultDisplayComponent: View {
    let result: HRAIImageResult
    let originalImageData: Data?
    let matchedLabels: [String]  // Matched segmentation labels from API (already matched by LLM)
    let segmentedObjects: [SegmentedObject]?  // Objects from segmentation 
    
    @State private var isGreyingOut = false
    @State private var greyedImage: UIImage?
    @State private var showGreyed = false  // Toggle between greyed and normal
    @State private var showCompareMode = false
    @State private var sliderPosition: CGFloat = 0
    @State private var afterImage: UIImage?
    @State private var isLoadingAfterImage = false
    @State private var hasAutoGreyed = false
    
    init(result: HRAIImageResult, originalImageData: Data? = nil, matchedLabels: [String] = [], segmentedObjects: [SegmentedObject]? = nil) {
        self.result = result
        self.originalImageData = originalImageData
        self.matchedLabels = matchedLabels
        self.segmentedObjects = segmentedObjects
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Generated Image - Takes most of the space
            if let urlString = result.imageURL, let url = URL(string: urlString) {
                imageContent(url: url)
            } else {
                noImageView
            }
        }
    }
    
    @ViewBuilder
    private func imageContent(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                loadingView
                
            case .success(let image):
                VStack(spacing: 16) {
                    // Main Image with optional compare slider
                    ZStack {
                        if showCompareMode, let originalData = originalImageData,
                           let originalUIImage = UIImage(data: originalData),
                           let afterUIImage = afterImage {
                            // Inline compare slider
                            inlineCompareSlider(before: originalUIImage, after: afterUIImage)
                        } else if let greyedUIImage = greyedImage, showGreyed {
                            Image(uiImage: greyedUIImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if isGreyingOut || isLoadingAfterImage {
                            Color.black.opacity(0.3)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.5)
                                Text("Processing furniture...")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Style badges - compact
                    HStack(spacing: 8) {
                        Badge(text: result.vibe, icon: "sparkles")
                        Badge(text: result.type, icon: "house.fill")
                        Spacer()
                    }
                    
                    // Action buttons
                    actionButtons(url: url, image: image)
                }
                .onAppear {
                    loadAfterImage(from: url)
                    // Auto-grey furniture when view appears if we have matched labels
                    if !hasAutoGreyed && !matchedLabels.isEmpty {
                        autoGreyFurniture(from: url)
                    }
                }
                
            case .failure:
                errorImageView
                
            @unknown default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Inline Compare Slider
    private func inlineCompareSlider(before: UIImage, after: UIImage) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Before image (left side - original)
                Image(uiImage: before)
                    .resizable()
                    .scaledToFit()
                
                // After image (right side - generated, masked)
                Image(uiImage: after)
                    .resizable()
                    .scaledToFit()
                    .mask {
                        Rectangle()
                            .offset(x: sliderPosition + geometry.size.width / 2)
                    }
                
                // Slider handle
                Rectangle()
                    .fill(.white)
                    .frame(width: 3)
                    .overlay {
                        Circle()
                            .fill(.white)
                            .frame(width: 36, height: 36)
                            .overlay {
                                HStack(spacing: 2) {
                                    Image(systemName: "chevron.left")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.caption.bold())
                                .foregroundColor(.gray)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }
                    .offset(x: sliderPosition)
                
                // Labels
                VStack {
                    HStack {
                        Text("Before")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(.black.opacity(0.6)))
                        
                        Spacer()
                        
                        Text("After")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(.black.opacity(0.6)))
                    }
                    .padding(8)
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let maxOffset = geometry.size.width / 2
                        sliderPosition = min(max(value.location.x - geometry.size.width / 2, -maxOffset), maxOffset)
                    }
            )
        }
        .aspectRatio(contentMode: .fit)
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading design...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    private var errorImageView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Failed to load image")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    private var noImageView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No image available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    private func actionButtons(url: URL, image: Image) -> some View {
        VStack(spacing: 12) {
            // Primary action row
            HStack(spacing: 12) {
                // Compare View Button
                if originalImageData != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCompareMode.toggle()
                            if showCompareMode {
                                sliderPosition = 0
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showCompareMode ? "xmark" : "slider.horizontal.below.rectangle")
                            Text(showCompareMode ? "Exit Compare" : "Compare")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(showCompareMode ? Color.gray : Color.primaryColor)
                        )
                    }
                    .disabled(isLoadingAfterImage)
                }
                
                // Grey Furniture Toggle - Only if we have a greyed image
                if !showCompareMode && greyedImage != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showGreyed.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showGreyed ? "eye.fill" : "eye.slash.fill")
                            Text(showGreyed ? "Show Design" : "Show Furniture")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primaryColor, lineWidth: 1.5)
                        )
                    }
                }
            }
            
            // Secondary actions row
            if !showCompareMode {
                HStack(spacing: 16) {
                    Spacer()
                    
                    // Share button
                    ShareLink(item: url) {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            Text("Share")
                                .font(.caption2)
                        }
                        .foregroundColor(.primaryColor)
                    }
                    
                    // Save button
                    Button {
                        saveImage(from: url)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title3)
                            Text("Save")
                                .font(.caption2)
                        }
                        .foregroundColor(.primaryColor)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func loadAfterImage(from url: URL) {
        guard afterImage == nil else { return }
        isLoadingAfterImage = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        afterImage = image
                        isLoadingAfterImage = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingAfterImage = false
                }
            }
        }
    }
    
    private func saveImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            } catch {
                print("Failed to save image: \(error)")
            }
        }
    }
    
    /// Auto-grey all matched furniture labels when view appears
    private func autoGreyFurniture(from url: URL) {
        guard !matchedLabels.isEmpty else {
            print("No matched labels to grey out")
            return
        }
        hasAutoGreyed = true
        isGreyingOut = true
        
        print("Starting auto-grey for labels: \(matchedLabels)")
        
        Task {
            do {
                // Download the image
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let originalImage = UIImage(data: data) else {
                    print("Failed to create UIImage from downloaded data")
                    await MainActor.run { isGreyingOut = false }
                    return
                }
                
                print("Downloaded image: \(originalImage.size)")
                
                // Grey out each matched label
                var resultImage = originalImage
                var successCount = 0
                
                for label in matchedLabels {
                    print("Attempting to grey out label: \(label)")
                    do {
                        let greyed = try await SegmentationAPI.shared.greyOutObject(in: resultImage, targetLabel: label)
                        resultImage = greyed
                        successCount += 1
                        print("Successfully greyed out: \(label)")
                    } catch {
                        print("Failed to grey out \(label): \(error)")
                        continue
                    }
                }
                
                print("Greying complete. Success count: \(successCount)")
                
                await MainActor.run {
                    if successCount > 0 {
                        greyedImage = resultImage
                        showGreyed = true
                        print("Set greyed image and showGreyed = true")
                    } else {
                        print("No labels were successfully greyed")
                    }
                    isGreyingOut = false
                }
            } catch {
                await MainActor.run {
                    isGreyingOut = false
                }
                print("Auto grey failed: \(error)")
            }
        }
    }
}

// MARK: - Badge Component
struct Badge: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundColor(.primaryColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.primaryColor.opacity(0.1))
        )
    }
}
