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
        let predicate = NSPredicate(value: true)
        let recordType = HRProductCategoryModelName.itemRecord
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
                self?.categories = returnedItems
            }
            .store(in: &cancellables)
    }
}
