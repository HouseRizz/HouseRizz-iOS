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
            
            await MainActor.run {
                self.generatedImageURL = response.generatedImageURL
                self.imageURL = response.generatedImageURL
                self.furnitureUsed = response.furnitureUsed ?? []
                self.segmentedObjects = response.segmentation?.objects
                self.matchedLabels = response.matchedLabels ?? []
                self.furnitureMarkers = response.furnitureMarkers ?? []
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
