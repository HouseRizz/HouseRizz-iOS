//
//  AddCitiesViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/07/24.
//

import SwiftUI
import Combine

@Observable
class AddCitiesViewModel {
    var error: String = ""
    var cities: [HRCity] = []
    var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()
    var urls: [URL] = []
    var errors: [Error] = []
    var name: String = ""
    
    func addButtonPressed(){
        guard !name.isEmpty else {return}
        addCity(name: name)
        
    }
    
    func clearItem() {
        error = ""
        name = ""
        selectedPhotoData = []
    }
    
    private func addCity(name: String) {
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
        
        guard let newCity = HRCity(id: UUID(), name: name, imageURL: urls[0] ) else {
            error = "Error creating item"
            return
        }
        
        CKUtility.add(item: newCity) { _ in }
    }
}
