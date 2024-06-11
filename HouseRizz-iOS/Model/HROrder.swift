//
//  HROrder.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import Foundation
import CloudKit

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
    static let itemRecord = "Orders"
}

struct HROrder: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let name: String
    let supplier: String
    let price: Double?
    let quantity: Int?
    let imageURL: URL?
    let buyerName: String
    let buyerEmail: String
    let buyerPhoneNumber: String?
    let buyerAddress: String?
    let dateOfOrder: TimeInterval
    let orderStatus: String
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HROrderModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HROrderModelName.name] as? String else { return nil }
        self.name = name
        guard let supplier = record[HROrderModelName.supplier] as? String else { return nil }
        self.supplier = supplier
        guard let price = record[HROrderModelName.price] as? Double else { return nil }
        self.price = price
        guard let quantity = record[HROrderModelName.quantity] as? Int else { return nil }
        self.quantity = quantity
        let imageAsset = record[HROrderModelName.imageURL] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        guard let buyerName = record[HROrderModelName.buyerName] as? String else { return nil }
        self.buyerName = buyerName
        guard let buyerEmail = record[HROrderModelName.buyerEmail] as? String else { return nil }
        self.buyerEmail = buyerEmail
        guard let buyerPhoneNumber = record[HROrderModelName.buyerPhoneNumber] as? String else { return nil }
        self.buyerPhoneNumber = buyerPhoneNumber
        guard let buyerAddress = record[HROrderModelName.buyerAddress] as? String else { return nil }
        self.buyerAddress = buyerAddress
        guard let dateOfOrder = record[HROrderModelName.dateOfOrder] as? TimeInterval else { return nil }
        self.dateOfOrder = dateOfOrder
        guard let orderStatus = record[HROrderModelName.orderStatus] as? String else { return nil }
        self.orderStatus = orderStatus
        self.record = record
    }
    
    init?(id: UUID, name: String, price: Double?, quantity: Int?, imageURL: URL?,  supplier: String? , buyerName: String, buyerEmail: String?, buyerPhoneNumber: String?, buyerAddress: String?, dateOfOrder: TimeInterval, orderStatus: String?) {
        let record = CKRecord(recordType: HROrderModelName.itemRecord)
        record[HROrderModelName.id] = id.uuidString
        record[HROrderModelName.name] = name
        record[HROrderModelName.supplier] = supplier
        record[HROrderModelName.price] = price
        record[HROrderModelName.quantity] = quantity
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record[HROrderModelName.imageURL] = asset
        }
        record[HROrderModelName.buyerName] = buyerName
        record[HROrderModelName.buyerEmail] = buyerEmail
        if (buyerPhoneNumber != nil) {
            record[HROrderModelName.buyerPhoneNumber] = buyerPhoneNumber
        }
        if (buyerAddress != nil) {
            record[HROrderModelName.buyerAddress] = buyerAddress
        }
        record[HROrderModelName.dateOfOrder] = dateOfOrder
        record[HROrderModelName.orderStatus] = orderStatus
        self.init(record: record)
    }
    
    func updateOrderStatus(status: String) -> HROrder? {
        let record = record
        record[HROrderModelName.orderStatus] = status
        return HROrder(record: record)
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

enum availableCities: CaseIterable {
    case delhi
    case agra
    
    var title: String {
        switch self {
        case .delhi:
            return "Delhi"
        case .agra:
            return "Agra"
        }
    }
}
