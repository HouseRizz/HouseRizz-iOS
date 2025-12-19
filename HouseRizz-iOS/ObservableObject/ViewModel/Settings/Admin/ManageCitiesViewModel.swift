//
//  ManageCitiesViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/07/24.
//

import Foundation
import Combine

@Observable
class ManageCitiesViewModel {
    var error: String = ""
    var cities: [HRCity] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchCities()
    }
    
    func fetchCities(){
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRCity]) in
                self?.cities = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func deleteCity(_ city: HRCity) {
        FirestoreUtility.delete(item: city)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .finished = completion {
                    self?.fetchCities()
                }
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
