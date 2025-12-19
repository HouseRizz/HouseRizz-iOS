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
        FirestoreUtility.fetch()
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
