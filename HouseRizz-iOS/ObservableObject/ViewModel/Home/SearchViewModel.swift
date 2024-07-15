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
}
