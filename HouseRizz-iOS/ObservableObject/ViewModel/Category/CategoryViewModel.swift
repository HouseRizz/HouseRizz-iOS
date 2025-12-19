//
//  CategoryViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import Combine

class CategoryViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var categories: [HRProductCategory] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchCategories()
    }

    func fetchCategories(){
        FirestoreUtility.fetch(sortBy: "name", ascending: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HRProductCategory]) in
                self?.categories = returnedItems
            }
            .store(in: &cancellables)
    }
}
