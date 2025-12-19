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
        FirestoreUtility.fetch()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRProduct]) in
                self?.products = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func fetchAddBanners(){
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRAddBanner]) in
                self?.adds = returnedItems
            }
            .store(in: &cancellables)
    }
}
