//
//  ManageOrdersViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import Foundation
import Combine

class VendorOrdersViewModel: ObservableObject {
    @Published var error: String = ""
    @Published var orders: [HROrder] = []
    @Published var userName: String = ""
    var cancellables = Set<AnyCancellable>()
    
    func fetchOrders(vendorName: String) {
        FirestoreUtility.fetch(field: "supplier", isEqualTo: vendorName)
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
