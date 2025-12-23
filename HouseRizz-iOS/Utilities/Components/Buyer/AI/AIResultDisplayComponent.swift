//
//  AIResultDisplayComponent.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI
import Combine

struct AIResultDisplayComponent: View {
    let result: HRAIImageResult
    let originalImageData: Data?
    let furnitureMarkers: [FurnitureMarker]
    
    @State private var selectedMarker: FurnitureMarker?
    @State private var showCompareMode = false
    @State private var sliderPosition: CGFloat = 0
    @State private var afterImage: UIImage?
    @State private var isLoadingAfterImage = false
    @State private var imageSize: CGSize = .zero
    
    init(result: HRAIImageResult, originalImageData: Data? = nil, furnitureMarkers: [FurnitureMarker] = []) {
        self.result = result
        self.originalImageData = originalImageData
        self.furnitureMarkers = furnitureMarkers
    }
    
    var body: some View {
        VStack(spacing: 12) {
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
                    // Main Image with furniture markers overlay
                    ZStack {
                        if showCompareMode, let originalData = originalImageData,
                           let originalUIImage = UIImage(data: originalData),
                           let afterUIImage = afterImage {
                            inlineCompareSlider(before: originalUIImage, after: afterUIImage)
                        } else {
                            // Generated image with marker dots overlay
                            image
                                .resizable()
                                .scaledToFit()
                                .overlay {
                                    GeometryReader { imageGeometry in
                                        let size = imageGeometry.size
                                        
                                        // Highlight effect for selected marker (behind dots)
                                        if let selected = selectedMarker {
                                            // Glowing border around furniture
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white, lineWidth: 3)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.white.opacity(0.25))
                                                )
                                                .frame(
                                                    width: max(50, (selected.box[2] - selected.box[0]) * size.width),
                                                    height: max(50, (selected.box[3] - selected.box[1]) * size.height)
                                                )
                                                .position(
                                                    x: selected.centerPoint.x * size.width,
                                                    y: selected.centerPoint.y * size.height
                                                )
                                                .shadow(color: .white.opacity(0.6), radius: 15)
                                                .allowsHitTesting(false)
                                        }
                                        
                                        // Furniture marker dots
                                        ForEach(furnitureMarkers) { marker in
                                            FurnitureMarkerDot(isSelected: selectedMarker?.id == marker.id) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    if selectedMarker?.id == marker.id {
                                                        selectedMarker = nil
                                                    } else {
                                                        selectedMarker = marker
                                                    }
                                                }
                                            }
                                            .position(
                                                x: marker.centerPoint.x * size.width,
                                                y: marker.centerPoint.y * size.height
                                            )
                                        }
                                    }
                                }
                                .onTapGesture {
                                    // Dismiss card when tapping outside
                                    if selectedMarker != nil {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedMarker = nil
                                        }
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                // Compare button overlay on image
                                .overlay(alignment: .bottomLeading) {
                                    if originalImageData != nil && !showCompareMode {
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showCompareMode = true
                                                sliderPosition = 0
                                                selectedMarker = nil
                                            }
                                        } label: {
                                            Image(systemName: "slider.horizontal.below.rectangle")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(width: 40, height: 40)
                                                .background(
                                                    Circle()
                                                        .fill(Color.primaryColor)
                                                        .shadow(color: .black.opacity(0.3), radius: 4)
                                                )
                                        }
                                        .disabled(isLoadingAfterImage)
                                        .padding(12)
                                    }
                                }
                        }
                        
                        // Exit compare mode button (shown when in compare mode)
                        if showCompareMode {
                            VStack {
                                Spacer()
                                HStack {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showCompareMode = false
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(
                                                Circle()
                                                    .fill(Color.gray)
                                                    .shadow(color: .black.opacity(0.3), radius: 4)
                                            )
                                    }
                                    .padding(12)
                                    Spacer()
                                }
                            }
                        }
                        
                        if isLoadingAfterImage {
                            Color.black.opacity(0.3)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        }
                    }
                    
                    // Product card popup with expandable similar products
                    if let marker = selectedMarker {
                        ExpandableFurnitureProductCard(
                            marker: marker,
                            onAddToCart: {
                                // TODO: Add to cart
                            },
                            onDismiss: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedMarker = nil
                                }
                            },
                            onProductTap: { product in
                                // TODO: Navigate to product detail
                                print("Tapped product: \(product.name)")
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.top, 8)
                    }
                    
                    // Style badges + action buttons in same row
                    VStack(alignment: .leading) {
                        HStack(spacing: 8){
                            Badge(text: result.vibe, icon: "sparkles")
                            Badge(text: result.type, icon: "house.fill")
                            
                            if !furnitureMarkers.isEmpty {
                                Badge(text: "\(furnitureMarkers.count) items", icon: "tag.fill")
                            }
                        }
                     
                        // Share & Save buttons (inline)
                        HStack(spacing: 8) {
                            ShareLink(item: url) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primaryColor)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.primaryColor.opacity(0.1))
                                    )
                            }
                            
                            Button {
                                saveImage(from: url)
                            } label: {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.primaryColor)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.primaryColor.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                .onAppear {
                    loadAfterImage(from: url)
                }
                
            case .failure:
                errorImageView
                
            @unknown default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Compare Slider
    private func inlineCompareSlider(before: UIImage, after: UIImage) -> some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: before)
                    .resizable()
                    .scaledToFit()
                
                Image(uiImage: after)
                    .resizable()
                    .scaledToFit()
                    .mask {
                        Rectangle()
                            .offset(x: sliderPosition + geometry.size.width / 2)
                    }
                
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
    
    /// Calculate the actual size of an image after scaledToFit within a container
    private func calculateImageSize(for image: Image, in containerSize: CGSize) -> CGSize {
        // Assume standard aspect ratio if we can't determine - use container size
        // For scaledToFit, the image will fit within the container maintaining aspect ratio
        // Since we don't have direct access to image dimensions from SwiftUI Image,
        // we'll use the container size (the image fills it with scaledToFit)
        return containerSize
    }
}

// MARK: - Preview
#Preview("AI Result Display") {
    ScrollView {
        AIResultDisplayComponent(
            result: HRAIImageResult(
                userName: "Preview User",
                imageURL: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800",
                vibe: "Minimalism",
                type: "Living Room"
            ),
            originalImageData: nil,
            furnitureMarkers: [
                FurnitureMarker(
                    name: "Modern Armchair",
                    type: "chair",
                    price: 299.99,
                    imageURL: nil,
                    description: "A beautiful modern armchair",
                    box: [0.1, 0.3, 0.4, 0.7],
                    maskColor: [100, 150, 200]
                ),
                FurnitureMarker(
                    name: "Coffee Table",
                    type: "table",
                    price: 199.99,
                    imageURL: nil,
                    description: "Elegant wooden coffee table",
                    box: [0.5, 0.5, 0.8, 0.8],
                    maskColor: [150, 100, 200]
                )
            ]
        )
        .padding()
    }
    .background(Color(UIColor.systemBackground))
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

// MARK: - Furniture Marker Dot
struct FurnitureMarkerDot: View {
    let isSelected: Bool
    var onTap: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            if !isSelected {
                Circle()
                    .fill(Color.brandOrangeSecondary)
                    .frame(width: 32, height: 32)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.6)
            }
            
            Circle()
                .fill(Color.brandOrange)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .scaleEffect(isSelected ? 1.2 : 1.0)
        }
        .onTapGesture {
            onTap()
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Furniture Product Card
struct FurnitureProductCard: View {
    let marker: FurnitureMarker
    var onShowSimilar: () -> Void
    var onAddToCart: () -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Product image
                if let imageURL = marker.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(marker.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(marker.type.capitalized)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let price = marker.formattedPrice {
                        Text(price)
                            .font(.title3.bold())
                            .foregroundColor(.primaryColor)
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            if let description = marker.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack(spacing: 12) {
                Button {
                    onShowSimilar()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                        Text("Show similar")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Button {
                    onAddToCart()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "cart.badge.plus")
                        Text("Add to cart")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryColor)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
        .overlay(alignment: .topTrailing) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.gray, Color(UIColor.systemBackground))
            }
            .padding(8)
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "chair.lounge.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            )
    }
}

// MARK: - Similar Products View
struct SimilarProductsView: View {
    let furnitureType: String
    var onProductTap: (HRProduct) -> Void
    
    @StateObject private var viewModel = SimilarProductsViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Similar Products")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if viewModel.products.isEmpty && !viewModel.isLoading {
                Text("No products found")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.products.prefix(10)) { product in
                            SimilarProductCard(product: product) {
                                onProductTap(product)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchProducts()
        }
    }
}

// MARK: - Similar Products ViewModel
class SimilarProductsViewModel: ObservableObject {
    @Published var products: [HRProduct] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchProducts() {
        guard products.isEmpty else { return }
        isLoading = true
        
        FirestoreUtility.fetch()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRProduct]) in
                self?.products = returnedItems
            }
            .store(in: &cancellables)
    }
}

// MARK: - Similar Product Card
struct SimilarProductCard: View {
    let product: HRProduct
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Product image
                if let imageURL = product.imageURL1, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            placeholderImage
                        default:
                            ProgressView()
                                .frame(width: 100, height: 100)
                        }
                    }
                } else {
                    placeholderImage
                }
                
                // Product name
                Text(product.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                // Price
                if let price = product.price {
                    Text(String(format: "₹%.0f", price))
                        .font(.caption.bold())
                        .foregroundColor(.primaryColor)
                }
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.gray)
            )
    }
}

// MARK: - Expandable Furniture Product Card (with Similar Products)
struct ExpandableFurnitureProductCard: View {
    let marker: FurnitureMarker
    var onAddToCart: () -> Void
    var onDismiss: () -> Void
    var onProductTap: (HRProduct) -> Void
    
    @State private var showSimilarProducts = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main product info
            HStack(alignment: .top, spacing: 12) {
                // Product image
                if let imageURL = marker.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(marker.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(marker.type.capitalized)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let price = marker.formattedPrice {
                        Text(price)
                            .font(.title3.bold())
                            .foregroundColor(.primaryColor)
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            if let description = marker.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showSimilarProducts.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showSimilarProducts ? 180 : 0))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showSimilarProducts)
                        
                        Text(showSimilarProducts ? "Hide similar" : "Show similar")
                            .contentTransition(.interpolate)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(showSimilarProducts ? .primaryColor : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(showSimilarProducts ? Color.primaryColor : Color.gray.opacity(0.3), lineWidth: showSimilarProducts ? 2 : 1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: showSimilarProducts)
                }
                
                Button {
                    onAddToCart()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "cart.badge.plus")
                        Text("Add to cart")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryColor)
                    )
                }
            }
            
            // Similar products section with smooth animation
            if showSimilarProducts {
                Divider()
                    .padding(.vertical, 4)
                
                SimilarProductsView(furnitureType: marker.type) { product in
                    onProductTap(product)
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity
                            .combined(with: .scale(scale: 0.95, anchor: .top))
                            .combined(with: .move(edge: .top)),
                        removal: .opacity
                            .combined(with: .scale(scale: 0.95, anchor: .top))
                    )
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
        .overlay(alignment: .topTrailing) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.gray, Color(UIColor.systemBackground))
            }
            .padding(8)
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "chair.lounge.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            )
    }
}
