//
//  ManageAddBannerViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import Combine

class ManageAddBannerViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var adds: [HRAddBanner] = []
    @Published var selectedPhotoData = [Data]()
    var cancellables = Set<AnyCancellable>()

    init(){
        fetchAddBanners()
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
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else {return}
        let item = adds[index]
        FirestoreUtility.delete(item: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.adds.remove(at: index)
            }
            .store(in: &cancellables)
    }
}
