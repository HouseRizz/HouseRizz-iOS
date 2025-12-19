//
//  OrderHistoryListViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 10/06/24.
//

import Foundation
import Combine

class OrderHistoryListViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var orders: [HROrder] = []
    @Published var userName: String = ""
    var cancellables = Set<AnyCancellable>()
    
    func fetchOrders(buyerName: String) {
        FirestoreUtility.fetch(field: "buyerName", isEqualTo: buyerName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (returnedItems: [HROrder]) in
                self?.orders = returnedItems
            }
            .store(in: &cancellables)
    }
}
