//  AIImageGenerationView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI
import PhotosUI
import RevenueCatUI
import RevenueCat

struct AIImageGenerationView: View {
    @StateObject private var authentication = Authentication()
    @Binding var isPremium: Bool
    @State private var viewModel = AIImageGenerationViewModel()
    @State private var navigateToGeneratedPhotoView = false
    @State private var hasReturnedFromGeneratedPhotoView = false
    @State var uniqueID: UUID = UUID()
    @State private var showAllResults: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    
    func checkPremiumStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                DispatchQueue.main.async {
                    isPremium = customerInfo.entitlements["premium"]?.isActive == true
                }
            } catch {
                print("Error checking premium status: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Logo Header
                Image("TextHouseRizz")
                    .resizable()
                    .frame(width: 150, height: 40)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Section
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Room Designer")
                                    .font(.title2.bold())
                                
                                Text("Transform your space with AI")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // History button
                            Button {
                                showAllResults = true
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.title3)
                                    .foregroundColor(.primaryColor)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(Color.primaryColor.opacity(0.1))
                                    )
                            }
                        }
                        .padding(.top, 12)
                        
                        // Photo Upload Section
                        photoUploadSection
                        
                        // Style Selection Section
                        styleSelectionSection
                        
                        // Room Type Section
                        roomTypeSection
                        
                        // Generate Button
                        generateButton
                        
                        // Error Display
                        if !viewModel.error.isEmpty {
                            errorView
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Extra padding for tab bar
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationDestination(isPresented: $navigateToGeneratedPhotoView) {
                GeneratedPhotoView(
                    uniqueID: uniqueID,
                    originalImageData: viewModel.selectedPhotoData,
                    matchedLabels: viewModel.matchedLabels,
                    segmentedObjects: viewModel.segmentedObjects
                )
            }
            .navigationDestination(isPresented: $showAllResults) {
                AllUserAIImageGenerationView(authentication: authentication)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView(image: $capturedImage)
            }
            .onChange(of: showPaywall) { _, newValue in
                if !newValue {
                    checkPremiumStatus()
                }
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    viewModel.selectedPhotoData = image.jpegData(compressionQuality: 0.8)
                }
            }
            .onChange(of: navigateToGeneratedPhotoView) { _, newValue in
                if !newValue {
                    hasReturnedFromGeneratedPhotoView = true
                    viewModel.generatedImageURL = nil
                    viewModel.selectedPhotoData = nil
                    viewModel.selectedPhotos = []
                    capturedImage = nil
                }
            }
            .onChange(of: viewModel.generatedImageURL) { _, newValue in
                if let url = newValue, !url.isEmpty, !hasReturnedFromGeneratedPhotoView {
                    viewModel.user = authentication.user?.email ?? "Not Provided"
                    viewModel.imageURL = url
                    viewModel.uniqueID = uniqueID
                    viewModel.addButtonPressed()
                    navigateToGeneratedPhotoView = true
                }
            }
        }
    }
    
    // MARK: - Photo Upload Section
    private var photoUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upload Your Room")
                .font(.headline)
            
            if let data = viewModel.selectedPhotoData, let uiImage = UIImage(data: data) {
                // Photo Preview
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Remove button
                    Button {
                        viewModel.selectedPhotoData = nil
                        viewModel.selectedPhotos = []
                        capturedImage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding(8)
                }
            } else {
                // Upload Options
                HStack(spacing: 12) {
                    // Camera Button
                    Button {
                        showCamera = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundColor(viewModel.isGenerating ? .gray : .primaryColor)
                            
                            Text("Take Photo")
                                .font(.subheadline)
                                .foregroundColor(viewModel.isGenerating ? .gray : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.isGenerating ? Color.gray.opacity(0.3) : Color.primaryColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isGenerating)
                    
                    // Gallery Button
                    PhotosPicker(
                        selection: $viewModel.selectedPhotos,
                        maxSelectionCount: 1,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title)
                                .foregroundColor(.primaryColor)
                            
                            Text("Choose Photo")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryColor.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isGenerating)
                }
                .onChange(of: viewModel.selectedPhotos) { _, _ in
                    viewModel.loadSelectedPhoto()
                }
            }
        }
    }
    
    // MARK: - Style Selection Section
    private var styleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Style")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.vibes.indices, id: \.self) { index in
                        styleCard(vibe: viewModel.vibes[index])
                    }
                }
            }
        }
    }
    
    private func styleCard(vibe: HRAIVibe) -> some View {
        Button {
            viewModel.vibe = vibe.name
        } label: {
            VStack(spacing: 8) {
                if let url = vibe.imageURLValue {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure(_):
                            placeholderStyleImage
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 80)
                        @unknown default:
                            placeholderStyleImage
                        }
                    }
                } else {
                    placeholderStyleImage
                }
                
                Text(vibe.name)
                    .font(.caption)
                    .fontWeight(viewModel.vibe == vibe.name ? .semibold : .regular)
                    .foregroundColor(viewModel.vibe == vibe.name ? .primaryColor : .primary)
                    .lineLimit(1)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.vibe == vibe.name ? Color.primaryColor.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.vibe == vibe.name ? Color.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .disabled(viewModel.isGenerating)
        .opacity(viewModel.isGenerating ? 0.6 : 1.0)
    }
    
    private var placeholderStyleImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(UIColor.tertiarySystemBackground))
            .frame(width: 100, height: 80)
            .overlay(
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(.gray)
            )
    }
    
    // MARK: - Room Type Section
    private var roomTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Room Type")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.categories.indices, id: \.self) { index in
                        roomTypeChip(category: viewModel.categories[index])
                    }
                }
            }
        }
    }
    
    private func roomTypeChip(category: HRProductCategory) -> some View {
        Button {
            viewModel.type = category.name
        } label: {
            Text(category.name)
                .font(.subheadline)
                .fontWeight(viewModel.type == category.name ? .semibold : .regular)
                .foregroundColor(viewModel.type == category.name ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(viewModel.type == category.name ? Color.primaryColor : Color(UIColor.secondarySystemBackground))
                )
        }
        .disabled(viewModel.isGenerating)
        .opacity(viewModel.isGenerating ? 0.6 : 1.0)
    }
    
    // MARK: - Generate Button
    private var generateButton: some View {
        Button {
            generateImage()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.selectedPhotoData != nil ? Color.primaryColor : Color.gray.opacity(0.3))
                    .frame(height: 50)
                
                if viewModel.isGenerating {
                    HStack(spacing: 12) {
                        // Custom loading dots
                        LoadingDotsView()
                        Text("Designing...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text("Generate Design")
                            .font(.headline)
                    }
                    .foregroundColor(viewModel.selectedPhotoData != nil ? .white : .gray)
                }
            }
        }
        .disabled(viewModel.selectedPhotoData == nil || viewModel.isGenerating)
        .padding(.top, 8)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(viewModel.error)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    func generateImage() {
        hasReturnedFromGeneratedPhotoView = false
        Task {
            try? await viewModel.generate()
        }
    }
}

// MARK: - Loading Dots Animation
struct LoadingDotsView: View {
    @State private var animationOffset: Int = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationOffset == index ? 1.3 : 0.7)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = 2
        }
    }
}

// MARK: - Camera Picker
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AIImageGenerationView(isPremium: .constant(false))
}
