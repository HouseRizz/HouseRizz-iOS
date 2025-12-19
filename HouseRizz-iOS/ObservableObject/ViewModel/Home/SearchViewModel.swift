//
//  SearchViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 12/06/24.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    @Published var selectedCity: String = "delhi"
    @Published var error: String = ""
    @Published var products: [HRProduct] = []
    var cancellables = Set<AnyCancellable>()
    @Published var search: String = ""
    @Published var showAlert: Bool = false
    
    var filteredProducts: [HRProduct] {
        guard !search.isEmpty else {return products}
        return products.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
    
    init(){
        fetchItems()
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
}
