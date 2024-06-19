//
//  AdminOrdersViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import Combine

class AdminOrdersViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var orders: [HROrder] = []
    var cancellables = Set<AnyCancellable>()
    
    func fetchOrders() {
        let predicate = NSPredicate(value: true)
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
