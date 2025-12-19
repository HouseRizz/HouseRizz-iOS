//
//  AdminInventoryViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import Combine

class AdminInventoryViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var products: [HRProduct] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        fetchItems()
    }
    
    func fetchItems(){
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
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
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else {return}
        let item = products[index]
        FirestoreUtility.delete(item: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.products.remove(at: index)
            }
            .store(in: &cancellables)
    }
}
