//
//  CartViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import Foundation

class CartViewModel: ObservableObject {
    @Published private(set) var products: [HRProduct] = []
    @Published private(set) var total: Int = 0
    
    func addToCart(product: HRProduct) {
        products.append(product)
        total += product.price
    }
    
    func removeToCart(product: HRProduct) {
        products = products.filter{$0.id != product.id}
        total -= product.price
    }
}
