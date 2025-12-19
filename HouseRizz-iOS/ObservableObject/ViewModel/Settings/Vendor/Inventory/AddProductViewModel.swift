//
//  AddProductViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import SwiftUI
import Combine
import RealityKit

class AddProductViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var sellingPrice: Double = 0
    @Published var taxRate: Double = 0
    @Published var modelURL: URL?
    @Published var selectedCategoryIndex: Int = 0
    @Published var supplier: String = ""
    @Published var address: String = ""
    @Published var selectedPhotoData = [Data]()
    @Published var isSuccess: Bool = false
    @Published var isLoaded: Bool = false
    @Published var categories: [HRProductCategory] = []
    var cancellables = Set<AnyCancellable>()
    var finalPrice: Double {
        let totalPrice = sellingPrice + (sellingPrice * taxRate / 100)
        return totalPrice
    }
    
    init() {
        fetchCategories()
    }
    
    func addButtonPressed(vendorName: String){
        guard !name.isEmpty else { return }
        addItem(name: name, vendorName: vendorName)
    }
    
    func clearItem() {
        error = ""
        name = ""
        description = ""
        sellingPrice = 0
        taxRate = 0
        supplier = ""
        selectedPhotoData = [Data]()
    }
    
    private func addItem(name: String, vendorName: String) {
        guard !selectedPhotoData.isEmpty else {
            error = "Please select at least one image"
            isLoaded = true
            return
        }
        
        let productId = UUID()
        let selectedCategory = categories.isEmpty ? "" : categories[selectedCategoryIndex].name
        
        // Upload images and model to Firebase Storage
        Task {
            do {
                var imageURLs: [String?] = [nil, nil, nil]
                
                // Upload images
                for (index, imageData) in selectedPhotoData.prefix(3).enumerated() {
                    let storagePath = "products/\(productId.uuidString)/image\(index + 1).jpg"
                    let url = try await FirestoreUtility.uploadImage(data: imageData, path: storagePath)
                    imageURLs[index] = url
                }
                
                // Upload 3D model if exists
                var modelURLString: String? = nil
                if let modelURL = modelURL {
                    let storagePath = "products/\(productId.uuidString)/model.usdz"
                    modelURLString = try await FirestoreUtility.uploadFile(from: modelURL, to: storagePath, contentType: "model/vnd.usdz+zip")
                }
                
                // Create and save product
                let newProduct = HRProduct(
                    id: productId,
                    name: name,
                    description: description,
                    price: finalPrice,
                    imageURL1: imageURLs[0],
                    imageURL2: imageURLs[1],
                    imageURL3: imageURLs[2],
                    modelURL: modelURLString,
                    category: selectedCategory,
                    supplier: vendorName,
                    address: address
                )
                
                _ = try await FirestoreUtility.add(item: newProduct)
                
                await MainActor.run {
                    self.isLoaded = true
                    self.isSuccess = true
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoaded = true
                }
            }
        }
    }
    
    func loadUSDZFile(from result: Result<URL, Error>) {
        do {
            let fileURL = try result.get()
            let tempFileURL = try createTempFileURL(from: fileURL)
            self.modelURL = tempFileURL
            fileURL.stopAccessingSecurityScopedResource()
        } catch {
            print("Unable to load USDZ file: \(error.localizedDescription)")
        }
    }

    func createTempFileURL(from fileURL: URL) throws -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString + ".usdz"
        let modelURL = tempDirectoryURL.appendingPathComponent(tempFileName)

        try FileManager.default.copyItem(at: fileURL, to: modelURL)
        return modelURL
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
