//
//  CartViewModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import Foundation

class CartViewModel: ObservableObject {
    @Published private(set) var products: [CartItem] = []
    @Published private(set) var total: Int = 0

    func addToCart(product: HRProduct) {
        if let index = products.firstIndex(where: { $0.product.id == product.id }) {
            products[index].quantity += 1
        } else {
            let cartItem = CartItem(product: product, quantity: 1)
            products.append(cartItem)
        }
        total += product.price
    }

    func removeFromCart(product: HRProduct) {
        if let index = products.firstIndex(where: { $0.product.id == product.id }) {
            let cartItem = products[index]
            if cartItem.quantity > 1 {
                products[index].quantity -= 1
            } else {
                products.remove(at: index)
            }
            total -= product.price
        }
    }
    
    func updateCartItemQuantity(cartItem: CartItem, newQuantity: Int) {
        if let index = products.firstIndex(where: { $0.product.id == cartItem.product.id }) {
            products[index].quantity = newQuantity
            total = products.reduce(0) { $0 + ($1.quantity * $1.product.price) }
        }
    }
}

struct CartItem {
    let product: HRProduct
    var quantity: Int
}
