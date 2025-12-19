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
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRAIVibe]) in
                self?.vibes = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func deleteVibe(_ vibe: HRAIVibe) {
        FirestoreUtility.delete(item: vibe)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .finished = completion {
                    self?.fetchVibes()
                }
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
