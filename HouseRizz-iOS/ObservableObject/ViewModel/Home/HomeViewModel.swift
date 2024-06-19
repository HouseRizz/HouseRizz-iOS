//
//  HomeViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 27/05/24.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var products: [HRProduct] = []
    var cancellables = Set<AnyCancellable>()
    @Published var city: String = ""
    var filteredProducts: [HRProduct] {
        guard !city.isEmpty else {return products}
        return products.filter { $0.address.localizedCaseInsensitiveContains(city) }
    }
    @Published var adds: [HRAddBanner] = []
    
    init(){
        fetchItems()
        fetchAddBanners()
    }
    
    func fetchItems(){
        let predicate = NSPredicate(value: true)
        let recordType = HRProductModelName.itemRecord
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
                self?.products = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func fetchAddBanners(){
        let predicate = NSPredicate(value: true)
        let recordType = HRAddBannerModelName.itemRecord
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
                self?.adds = returnedItems
            }
            .store(in: &cancellables)
    }
}

