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
        guard let imageData = selectedPhotoData.first else {
            error = "Please select an image"
            return
        }
        
        let cityId = UUID()
        let storagePath = "cities/\(cityId.uuidString)/image.jpg"
        
        // Upload image to Firebase Storage, then create city
        FirestoreUtility.uploadImage(data: imageData, path: storagePath) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    let newCity = HRCity(id: cityId, name: name, imageURL: imageURL)
                    FirestoreUtility.add(item: newCity) { _ in }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
