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
        let predicate = NSPredicate(format: "%K == %@", HRAIImageResultModelName.id, uniqueID.uuidString)
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
                self?.aiResult = returnedItems.first
            }
            .store(in: &cancellables)
    }
}
