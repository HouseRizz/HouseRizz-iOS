//
//  ProductCategoryViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 05/06/24.
//

import Foundation
import Combine

class ProductCategoryViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var products: [HRProduct] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        fetchItems()
    }
    
    func fetchItems(){
        let predicate = NSPredicate(value: true)
        let recordType = "Items"
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
