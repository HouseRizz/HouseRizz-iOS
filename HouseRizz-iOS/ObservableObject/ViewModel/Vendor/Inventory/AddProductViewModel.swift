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
    @Published var imageURL1: String = ""
    @Published var imageURL2: String = ""
    @Published var imageURL3: String = ""
    @Published var modelURL: URL?
    @Published var selectedCategory: Category = .sofa
    @Published var supplier: String = ""
    @Published var address: String = ""
    @Published var selectedPhotoData = [Data]()
    @Published var isSuccess: Bool = false
    @Published var isLoaded: Bool = false
    var urls: [URL] = []
    var errors: [Error] = []
    var cancellables = Set<AnyCancellable>()
    var finalPrice: Double {
        let totalPrice = sellingPrice + (sellingPrice * taxRate / 100)
        return totalPrice
    }
    
    func addButtonPressed(vendorName: String){
        guard !name.isEmpty else {return}
        addItem(name: name, vendorName: vendorName)
        
    }
    
    func clearItem() {
        error = ""
        name = ""
        description = ""
        sellingPrice = 0
        taxRate = 0
        imageURL1 = ""
        imageURL2 = ""
        imageURL3 = ""
        supplier = ""
        selectedPhotoData = [Data]()
    }
    
    private func addItem(name: String, vendorName: String) {
        guard !selectedPhotoData.isEmpty else {
            error = "Please select at least one image"
            return
        }
        
        for (index, imageData) in selectedPhotoData.enumerated() {
            guard let image = UIImage(data: imageData),
                  let url = FileManager
                                .default
                                .urls(for: .cachesDirectory, in: .userDomainMask)
                                .first?.appendingPathComponent("photo\(index + 1).jpg"),
                  let data = image.jpegData(compressionQuality: 1.0) else { continue }
            do {
                try data.write(to: url)
                urls.append(url)
            } catch {
                errors.append(error)
            }
        }
        
        guard let newItem = HRProduct(id: UUID(), name: name, description: description, price: finalPrice, imageURL1: urls.count > 0 ? urls[0] : nil, imageURL2: urls.count > 1 ? urls[1] : nil, imageURL3: urls.count > 2 ? urls[2] : nil, modelURL: modelURL, category: selectedCategory.title, supplier: vendorName, address: address) else {
            error = "Error creating item"
            isLoaded = true
            return
        }
        
        CKUtility.add(item: newItem) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isLoaded = true
                self?.isSuccess = true
            }
        }
    }
    
    func loadUSDZFile(from result: Result<URL, Error>) {
        do {
            let fileURL = try result.get()
//            try fileURL.startAccessingSecurityScopedResource()
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
}

