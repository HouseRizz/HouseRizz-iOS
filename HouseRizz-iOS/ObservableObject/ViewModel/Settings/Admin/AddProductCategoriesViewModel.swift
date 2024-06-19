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
    var urls: [URL] = []
    var errors: [Error] = []
    
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
        
        guard let newCategory = HRProductCategory(id: UUID(), name: name, imageURL: urls[0] ) else {
            error = "Error creating item"
            return
        }
        
        CKUtility.add(item: newCategory) { _ in }
    }
    
}
