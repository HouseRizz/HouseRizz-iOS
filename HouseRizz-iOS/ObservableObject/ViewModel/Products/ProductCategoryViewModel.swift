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
