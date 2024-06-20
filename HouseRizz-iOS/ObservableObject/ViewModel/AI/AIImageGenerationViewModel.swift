//
//  AIImageGenerationViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import SwiftUI
import Replicate
import Combine
import PhotosUI

class AIImageGenerationViewModel: ObservableObject {
    @Published var type: String = "Bed"
    @Published var vibe: String = "Modern"
    @Published var apis: [HRAPI] = []
    @Published var error: String = ""
    @Published var selectedPhotoData: Data? = nil
    let negativePrompt = "lowres, watermark, banner, logo, watermark, contactinfo, text, deformed, blurry, blur, out of focus, out of frame, surreal, extra, ugly, upholstered walls, fabric walls, plush walls, mirror, mirrored, functional, realistic"
    var prediction: InteriorDesign.Prediction? = nil
    @Published var selectedPhotos: [PhotosPickerItem] = []
    var cancellables = Set<AnyCancellable>()
    @Published var categories: [HRProductCategory] = []

    private var client: Replicate.Client? {
        apis.first.flatMap { Replicate.Client(token: $0.api) }
    }

    var prompt: String {
        "A \(vibe) \(type) interior design with enhanced aesthetics, optimized layout, and improved functionality. The design should emphasize elements such as \(vibe) furniture, \(vibe) decor. Ensure the design is realistic and visually appealing."
    }

    init() {
        fetchAPI()
        fetchCategories()
    }
    
    func loadSelectedPhoto() {
        guard let selectedPhoto = selectedPhotos.first else {
            return
        }
        
        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                DispatchQueue.main.async {
                    self.selectedPhotoData = data
                }
            }
        }
    }

    func generate() async throws {
        guard let selectedPhotoData = selectedPhotoData else {
            error = "No photo selected."
            return
        }

        let mimeType = "image/jpeg"
        let imageString = selectedPhotoData.uriEncoded(mimeType: mimeType)

        guard let client = client else {
            error = "Client not initialized."
            return
        }

        let input = InteriorDesign.Input(
            image: imageString,
            prompt: prompt,
            seed: nil,
            guidance_scale: 15,
            negative_prompt: negativePrompt,
            prompt_strength: 0.8,
            num_inference_steps: 50
        )

        prediction = try await InteriorDesign.predict(with: client, input: input)
        try await prediction?.wait(with: client)
    }

    func fetchAPI() {
        let predicate = NSPredicate(format: "%K == %@", HRAPIModelName.name, "Replicate")
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
                print("\(self?.apis.first?.name ?? "none")")
            }
            .store(in: &cancellables)
    }

    func fetchCategories(){
        let predicate = NSPredicate(value: true)
        let recordType = HRProductCategoryModelName.itemRecord
        CKUtility.fetch(predicate: predicate, recordType: recordType, sortDescription: [NSSortDescriptor(key: "name", ascending: true)])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] returnedItems in
                self?.categories = returnedItems
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

extension Data {
    func uriEncoded(mimeType: String) -> String {
        let base64String = self.base64EncodedString()
        return "data:\(mimeType);base64,\(base64String)"
    }
}
