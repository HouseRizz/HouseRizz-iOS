//
//  GeneratedPhotoViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import Foundation
import Combine

@Observable
class GeneratedPhotoViewModel {
    var error: String = ""
    var aiResult: HRAIImageResult?
    var cancellables = Set<AnyCancellable>()
    
    func fetchResult(for uniqueID: UUID) {
        FirestoreUtility.fetch(field: "id", isEqualTo: uniqueID.uuidString)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRAIImageResult]) in
                self?.aiResult = returnedItems.first
            }
            .store(in: &cancellables)
    }
}
