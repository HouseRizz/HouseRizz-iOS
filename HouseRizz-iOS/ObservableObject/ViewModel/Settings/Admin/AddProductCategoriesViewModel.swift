//
//  AddProductCategoriesViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI
import Combine

class AddProductCategoriesViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var categories: [HRProductCategory] = []
    @Published var name: String = ""
    @Published var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()
    
    func addButtonPressed(){
        guard !name.isEmpty else {return}
        addCategory(name: name)
    }
    
    func clearItem() {
        error = ""
        name = ""
        selectedPhotoData = []
    }
    
    private func addCategory(name: String) {
        guard let imageData = selectedPhotoData.first else {
            error = "Please select an image"
            return
        }
        
        let categoryId = UUID()
        let storagePath = "categories/\(categoryId.uuidString)/image.jpg"
        
        // Upload image to Firebase Storage, then create category
        FirestoreUtility.uploadImage(data: imageData, path: storagePath) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    let newCategory = HRProductCategory(id: categoryId, name: name, imageURL: imageURL)
                    FirestoreUtility.add(item: newCategory) { _ in }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
