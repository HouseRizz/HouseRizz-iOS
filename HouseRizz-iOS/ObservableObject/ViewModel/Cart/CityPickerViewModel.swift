//
//  CityPickerViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/07/24.
//

import Foundation
import Combine

@Observable
class CityPickerViewModel {
    var error: String = ""
    var cities: [HRCity] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchCities()
    }
    
    func fetchCities(){
        let predicate = NSPredicate(value: true)
        let recordType = HRCityModelName.itemRecord
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
                self?.cities = returnedItems
            }
            .store(in: &cancellables)
    }
}
