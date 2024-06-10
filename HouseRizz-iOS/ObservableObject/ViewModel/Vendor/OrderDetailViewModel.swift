//
//  OrderDetailViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 09/06/24.
//

import Foundation
import Combine

class OrderDetailViewModel: ObservableObject {
    
    @Published var selectedOrderStatus: OrderStatus
    @Published var error: String = ""
    @Published var supplier: String = ""
    @Published var isChangedStatus: Bool = false
    var cancellables = Set<AnyCancellable>()
    
    init(initialStatus: OrderStatus) {
        self.selectedOrderStatus = initialStatus
    }

    func updateOrderStatus(order: HROrder) {
        guard let newOrder = order.updateOrderStatus(status: selectedOrderStatus.title) else { return }
        CKUtility.update(item: newOrder) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isChangedStatus.toggle()
            }
        }
    }
}
