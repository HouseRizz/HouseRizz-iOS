//
//  ManageProductCategoriesViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import SwiftUI
import Combine

class ManageProductCategoriesViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var categories: [HRProductCategory] = []
    @Published var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()
    
    init(){
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
    
    func deleteCategory(_ category: HRProductCategory) {
        FirestoreUtility.delete(item: category)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .finished = completion {
                    self?.fetchCategories()
                }
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
