//
//  ManageOrdersViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import Foundation
import Combine

class ManageOrdersViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var orders: [HROrder] = []
    @Published var userName: String = ""
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getCurrentUserName()
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
            } receiveValue: { [weak self] userName in
                self?.userName = userName
                self?.fetchOrders()
            }
            .store(in: &cancellables)
    }
    
    func fetchOrders() {
        
        let predicate = NSPredicate(format: "%K == %@", HROrderModelName.supplier, userName)
        let recordType = HROrderModelName.itemRecord
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
                self?.orders = returnedItems
            }
            .store(in: &cancellables)
    }
}
