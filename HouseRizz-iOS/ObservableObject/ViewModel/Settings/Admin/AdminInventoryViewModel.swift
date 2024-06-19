//
//  AdminInventoryViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import Combine

class AdminInventoryViewModel: ObservableObject {
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    @Published var permissionStatus: Bool = false
    @Published var products: [HRProduct] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        getiCloudStatus()
        requestPermission()
    }
    
    private func getiCloudStatus(){
        CKUtility.getiCloudStatus()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.isSignedInToiCloud = success
            }
            .store(in: &cancellables)
    }
    
    func requestPermission(){
        CKUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.permissionStatus = success
            }
            .store(in: &cancellables)
    }
    
    func fetchItems(){
        let predicate = NSPredicate(value: true)
        let recordType = HRProductModelName.itemRecord
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
                self?.products = returnedItems
            }
            .store(in: &cancellables)
    }
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else {return}
        let item = products[index]
        CKUtility.delete(item: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.products.remove(at: index)
            }
            .store(in: &cancellables)
    }
}

