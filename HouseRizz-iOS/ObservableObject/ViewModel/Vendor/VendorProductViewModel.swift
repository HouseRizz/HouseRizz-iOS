//
//  VendorProductViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import Foundation
import Combine

class VendorProductViewModel: ObservableObject {
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    @Published var permissionStatus: Bool = false
    @Published var userName: String = ""
    @Published var products: [HRProduct] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        getiCloudStatus()
        requestPermission()
        getCurrentUserName()
        fetchItems()
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
    
    func getCurrentUserName() {
        CKUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.userName = success
            }
            .store(in: &cancellables)
    }
    
    func fetchItems(){
        let predicate = NSPredicate(format: "%K == %@", HRProductModelName.supplier, userName)
        let recordType = "Items"
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

