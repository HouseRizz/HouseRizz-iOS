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
    
    var cancellables = Set<AnyCancellable>()

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
