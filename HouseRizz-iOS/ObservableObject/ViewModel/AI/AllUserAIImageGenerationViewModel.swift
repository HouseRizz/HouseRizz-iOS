//
//  AllUserAIImageGenerationViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import Foundation
import Combine

@Observable
class AllUserAIImageGenerationViewModel {
    var error: String = ""
    var aiResult: [HRAIImageResult]?
    var cancellables = Set<AnyCancellable>()
    
    func fetchResult(for userName: String) {
        FirestoreUtility.fetch(field: "userName", isEqualTo: userName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRAIImageResult]) in
                self?.aiResult = returnedItems
            }
            .store(in: &cancellables)
    }
}
