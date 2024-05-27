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
    @Published var price: Int = 0
    @Published var imageURL1: String = ""
    @Published var imageURL2: String = ""
    @Published var imageURL3: String = ""
    @Published var modelURL: URL?
    @Published var category: String = ""
    @Published var selectedCategory: Category = .sofa
    @Published var supplier: String = ""
    @Published var items: [HRProduct] = []
    @Published var selectedPhotoData = [Data]()
    var urls: [URL] = []
    var errors: [Error] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        getCurrentUserName()
    }
    
    func addButtonPressed(){
        guard !name.isEmpty else {return}
        addItem(name: name)
        
    }
    
    private func clearItem() {
        error = ""
        name = ""
        description = ""
        price = 0
        imageURL1 = ""
        imageURL2 = ""
        imageURL3 = ""
        category = ""
        supplier = ""
        items = []
        selectedPhotoData = [Data]()
    }
    
    private func addItem(name: String) {
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
        
        guard let newItem = HRCKProduct(id: UUID(), name: name, description: description, price: price, imageURL1: urls.count > 0 ? urls[0] : nil, imageURL2: urls.count > 1 ? urls[1] : nil, imageURL3: urls.count > 2 ? urls[2] : nil, modelURL: modelURL, category: selectedCategory.title, supplier: supplier) else {
            error = "Error creating item"
            return
        }
        
        CKUtility.add(item: newItem) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.clearItem()
            }
        }
    }
    
    func loadUSDZFile(from result: Result<URL, Error>) {
        do {
            let fileURL = try result.get()
            try fileURL.startAccessingSecurityScopedResource()
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
    
    func getCurrentUserName() {
        CKUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.supplier = success
            }
            .store(in: &cancellables)
    }
}

