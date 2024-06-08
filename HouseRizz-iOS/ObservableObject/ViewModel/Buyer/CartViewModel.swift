//
//  CartViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published private(set) var products: [HRCartItem] = []
    @Published private(set) var total: Int = 0
    @Published var orderId = UUID()
    @Published var dateOfOrder = Date()
    @Published var orderStatus: String? = "To be Confirmed"
    
    func sendOrder(buyerName: String, buyerEmail: String, buyerPhoneNumber: String?, buyerAddress: String?) {
        for product in products {
            guard let newOrder = HROrder(id: orderId,
                                         name: product.product.name,
                                         price: product.product.price,
                                         quantity: product.quantity,
                                         supplier: product.product.supplier,
                                         buyerName: buyerName,
                                         buyerEmail: buyerEmail,
                                         buyerPhoneNumber: buyerPhoneNumber,
                                         buyerAddress: buyerAddress,
                                         dateOfOrder: dateOfOrder.timeIntervalSince1970,
                                         orderStatus: orderStatus)
                    
            else { continue }
            CKUtility.add(item: newOrder) { _ in }
        }
    }
}

extension CartViewModel {
    func addToCart(product: HRProduct, quantity: Int = 1) {
        if let index = products.firstIndex(where: { $0.product.id == product.id }) {
            products[index].quantity += quantity
        } else {
            let cartItem = HRCartItem(product: product, quantity: quantity)
            products.append(cartItem)
        }
        total += Int((product.price ?? 0)) * quantity
    }
    
    func removeFromCart(product: HRProduct) {
        if let index = products.firstIndex(where: { $0.product.id == product.id }) {
            let cartItem = products[index]
            if cartItem.quantity > 1 {
                products[index].quantity -= 1
            } else {
                products.remove(at: index)
            }
            total -= Int(product.price ?? 0)
        }
    }
    
    func updateCartItemQuantity(cartItem: HRCartItem, newQuantity: Int) {
        if let index = products.firstIndex(where: { $0.product.id == cartItem.product.id }) {
            products[index].quantity = newQuantity
            total = products.reduce(0) { $0 + ($1.quantity * Int(($1.product.price ?? 0))) }
        }
    }
}


