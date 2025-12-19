//
//  AddAIVibeViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import SwiftUI
import Combine

@Observable
class AddAIVibeViewModel {
    var error: String = ""
    var vibes: [HRAIVibe] = []
    var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()
    var name: String = ""
    
    func addButtonPressed(){
        guard !name.isEmpty else {return}
        addVibe(name: name)
    }
    
    func clearItem() {
        error = ""
        name = ""
        selectedPhotoData = []
    }
    
    private func addVibe(name: String) {
        guard let imageData = selectedPhotoData.first else {
            error = "Please select an image"
            return
        }
        
        let vibeId = UUID()
        let storagePath = "vibes/\(vibeId.uuidString)/image.jpg"
        
        // Upload image to Firebase Storage, then create vibe
        FirestoreUtility.uploadImage(data: imageData, path: storagePath) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    let newVibe = HRAIVibe(id: vibeId, name: name, imageURL: imageURL)
                    FirestoreUtility.add(item: newVibe) { _ in }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
