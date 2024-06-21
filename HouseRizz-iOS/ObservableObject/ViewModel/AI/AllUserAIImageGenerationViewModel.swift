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
        let predicate = NSPredicate(format: "%K == %@", HRAIImageResultModelName.userName, userName)
        let recordType = HRAIImageResultModelName.itemRecord
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
                self?.aiResult = returnedItems
            }
            .store(in: &cancellables)
    }
}
