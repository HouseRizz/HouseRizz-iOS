//
//  AIImageGenerationViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI
import Combine
import PhotosUI
import Observation

@Observable
class AIImageGenerationViewModel {
    var type: String = "Bedroom"
    var vibe: String = "Modern"
    var error: String = ""
    var selectedPhotoData: Data? = nil
    var selectedPhotos: [PhotosPickerItem] = []
    var cancellables = Set<AnyCancellable>()
    var categories: [HRProductCategory] = []
    var uniqueID: UUID = UUID()
    var vibes: [HRAIVibe] = []
    
    // Result from API
    var generatedImageURL: String? = nil
    var furnitureUsed: [FurnitureUsed] = []
    var segmentedObjects: [SegmentedObject]? = nil
    var matchedLabels: [String] = []
    var furnitureMarkers: [FurnitureMarker] = []  // For interactive overlay
    var isGenerating: Bool = false
    
    var prompt: String {
        "\(vibe) \(type) interior design"
    }
    var user: String = ""
    var imageURL: String = ""
    
    init() {
        fetchCategories()
        fetchVibes()
    }
    
    func addButtonPressed() {
        guard !user.isEmpty else { return }
        addResult(user: user)
    }
    
    func clearItem() {
        error = ""
        user = ""
        selectedPhotoData = nil
        generatedImageURL = nil
        furnitureUsed = []
        segmentedObjects = nil
        matchedLabels = []
        furnitureMarkers = []
    }
    
    private func addResult(user: String) {
        let newResult = HRAIImageResult(
            id: uniqueID,
            userName: user,
            imageURL: imageURL,
            vibe: vibe,
            type: type,
            created: Date().timeIntervalSince1970
        )
        
        FirestoreUtility.add(item: newResult) { _ in }
    }
    
    func loadSelectedPhoto() {
        guard let selectedPhoto = selectedPhotos.first else {
            return
        }
        
        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                DispatchQueue.main.async {
                    self.selectedPhotoData = data
                }
            }
        }
    }
    
    /// Generate room design using the Virtual Staging API
    func generate() async throws {
        guard let selectedPhotoData = selectedPhotoData else {
            error = "No photo selected."
            return
        }
        
        isGenerating = true
        error = ""
        
        do {
            let response = try await VirtualStagingAPIService.shared.designRoom(
                imageData: selectedPhotoData,
                vibe: prompt
            )
            
            // Enrich markers with real products from inventory
            let enriched = await enrichMarkers(response.furnitureMarkers ?? [])
            
            await MainActor.run {
                self.generatedImageURL = response.generatedImageURL
                self.imageURL = response.generatedImageURL
                self.furnitureUsed = response.furnitureUsed ?? []
                self.segmentedObjects = response.segmentation?.objects
                self.matchedLabels = response.matchedLabels ?? []
                self.furnitureMarkers = enriched
                self.isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isGenerating = false
            }
            throw error
        }
    }
    
    /// Map generic furniture markers to real products from Firestore
    private func enrichMarkers(_ markers: [FurnitureMarker]) async -> [FurnitureMarker] {
        // Fetch products for the current room category/type
        // We use 'type' (e.g. "Bedroom") as the category filter
        guard let products: [HRProduct] = try? await FirestoreUtility.fetch(field: "category", isEqualTo: self.type) else {
            return markers
        }
        
        var enrichedMarkers: [FurnitureMarker] = []
        
        for marker in markers {
            // Find products where name matches (case-insensitive)
            // The user specified matching the inventory name with the product name
            let matchingProducts = products.filter { product in
                product.name.localizedCaseInsensitiveContains(marker.name) ||
                marker.name.localizedCaseInsensitiveContains(product.name)
            }
            
            // Only use the first match if found. 
            // If no match is found, we keep the original marker (generic info) 
            // instead of showing a random (incorrect) product.
            if let product = matchingProducts.first {
                let enriched = FurnitureMarker(
                    name: product.name,
                    type: marker.type,
                    price: product.price,
                    imageURL: product.imageURL1,
                    description: product.description,
                    sourceUrl: product.sourceUrl,
                    box: marker.box,
                    maskColor: marker.maskColor
                )
                enrichedMarkers.append(enriched)
            } else {
                enrichedMarkers.append(marker)
            }
        }
        
        return enrichedMarkers
    }
    
    func fetchVibes() {
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRAIVibe]) in
                self?.vibes = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func fetchCategories() {
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRProductCategory]) in
                self?.categories = returnedItems
            }
            .store(in: &cancellables)
    }
}
