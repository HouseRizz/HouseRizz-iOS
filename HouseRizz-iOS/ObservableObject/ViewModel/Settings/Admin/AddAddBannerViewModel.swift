//
//  AddAddBannerViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI
import Combine

class AddAddBannerViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var banners: [HRAddBanner] = []
    @Published var name: String = ""
    @Published var sliderNumber: Int = 1
    @Published var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()
    
    func addButtonPressed(){
        guard !name.isEmpty else {return}
        addBanner(name: name)
    }
    
    func clearItem() {
        error = ""
        name = ""
        selectedPhotoData = []
    }
    
    private func addBanner(name: String) {
        guard let imageData = selectedPhotoData.first else {
            error = "Please select an image"
            return
        }
        
        let bannerId = UUID()
        let storagePath = "banners/\(bannerId.uuidString)/image.jpg"
        
        // Upload image to Firebase Storage, then create banner
        FirestoreUtility.uploadImage(data: imageData, path: storagePath) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let imageURL):
                    let newBanner = HRAddBanner(id: bannerId, name: name, imageURL: imageURL, sliderNumber: self.sliderNumber)
                    FirestoreUtility.add(item: newBanner) { _ in }
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }
        }
    }
}
