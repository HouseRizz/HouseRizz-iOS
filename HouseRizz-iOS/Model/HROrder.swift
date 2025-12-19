//
//  HROrder.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import Foundation

struct HROrderModelName {
    static let id = "id"
    static let name = "name"
    static let supplier = "supplier"
    static let price = "price"
    static let quantity = "quantity"
    static let imageURL = "imageURL"
    static let buyerName = "buyerName"
    static let buyerEmail = "buyerEmail"
    static let buyerPhoneNumber = "buyerPhoneNumber"
    static let buyerAddress = "buyerAddress"
    static let dateOfOrder = "dateOfOrder"
    static let orderStatus = "orderStatus"
}

struct HROrder: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "orders"
    
    var id: UUID
    let name: String
    let supplier: String
    let price: Double?
    let quantity: Int?
    let imageURL: String?
    let buyerName: String
    let buyerEmail: String
    let buyerPhoneNumber: String?
    let buyerAddress: String?
    let dateOfOrder: TimeInterval
    var orderStatus: String
    
    init(
        id: UUID = UUID(),
        name: String,
        price: Double? = nil,
        quantity: Int? = nil,
        imageURL: String? = nil,
        supplier: String,
        buyerName: String,
        buyerEmail: String,
        buyerPhoneNumber: String? = nil,
        buyerAddress: String? = nil,
        dateOfOrder: TimeInterval = Date().timeIntervalSince1970,
        orderStatus: String = OrderStatus.toBeConfirmed.title
    ) {
        self.id = id
        self.name = name
        self.supplier = supplier
        self.price = price
        self.quantity = quantity
        self.imageURL = imageURL
        self.buyerName = buyerName
        self.buyerEmail = buyerEmail
        self.buyerPhoneNumber = buyerPhoneNumber
        self.buyerAddress = buyerAddress
        self.dateOfOrder = dateOfOrder
        self.orderStatus = orderStatus
    }
    
    /// Convenience computed property to get URL from string
    var imageURLValue: URL? {
        guard let urlString = imageURL else { return nil }
        return URL(string: urlString)
    }
    
    /// Returns a new order with updated status
    func withUpdatedStatus(_ status: String) -> HROrder {
        var updatedOrder = self
        updatedOrder.orderStatus = status
        return updatedOrder
    }
}

enum OrderStatus: CaseIterable {
    case toBeConfirmed
    case confirmed
    case dispatched
    case delivered
    case cancelled
        
    var title: String {
        switch self {
        case .toBeConfirmed:
            return "To Be Confirmed"
        case .confirmed:
            return "Confirmed"
        case .dispatched:
            return "Dispatched"
        case .delivered:
            return "Delivered"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    init?(statusString: String) {
        switch statusString {
        case "To Be Confirmed":
            self = .toBeConfirmed
        case "Confirmed":
            self = .confirmed
        case "Dispatched":
            self = .dispatched
        case "Delivered":
            self = .delivered
        case "Cancelled":
            self = .cancelled
        default:
            return nil
        }
    }
}
