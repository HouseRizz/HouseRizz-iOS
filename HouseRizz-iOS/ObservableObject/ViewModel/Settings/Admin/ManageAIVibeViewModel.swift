//
//  ManageAIVibeViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import Foundation
import Combine

@Observable
class ManageAIVibeViewModel {
    var error: String = ""
    var vibes: [HRAIVibe] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchVibes()
    }
    
    func fetchVibes(){
        let predicate = NSPredicate(value: true)
        let recordType = HRAIVibeModelName.itemRecord
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
                self?.vibes = returnedItems
            }
            .store(in: &cancellables)
    }
}
