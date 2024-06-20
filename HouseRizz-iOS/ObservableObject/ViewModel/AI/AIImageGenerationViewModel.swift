//
//  AIImageGenerationViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import Foundation
import Replicate
import Combine


class AIImageGenerationViewModel: ObservableObject {
    @Published var type: String = "Bed"
    @Published var vibe: String = "Modern"
    @Published var apis: [HRAPI] = []
    @Published var error: String = ""
    
    var cancellables = Set<AnyCancellable>()
    
    func fetchAPI(){
        let predicate = NSPredicate(format: "%K == %@", HRAPIModelName.api, "Replicate HR Key")
        let recordType = HRAPIModelName.itemRecord
        CKUtility.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] returnedItems in
                self?.apis = returnedItems
            }
            .store(in: &cancellables)
    }

}

enum InteriorDesign: Predictable {
    static var modelID = "adirik/interior-design"
    static let versionID = "76604baddc85b1b4616e1c6475eca080da339c8875bd4996705440484a6eac38"
    
    struct Input: Codable {
        let image: String  // Image data URI-encoded string
        let prompt: String
        let seed: Int?
        let guidance_scale: Double
        let negative_prompt: String
        let prompt_strength: Double
        let num_inference_steps: Int
    }
    
    typealias Output = URL
}
