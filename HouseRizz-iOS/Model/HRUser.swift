//
//  HRUser.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import Foundation
import CloudKit

struct HRUserModelName {
    static let id = "id"
    static let name = "name"
    static let userType = "userType"
    static let email = "email"
    static let phoneNumber = "phoneNumber"
    static let address = "address"
    static let joined = "joined"
    static let itemRecord = "SignedInUsers"
}

struct HRUser: Encodable, Hashable, Identifiable, CKitableProtocol {
    let id: String
    let name: String
    let email: String
    let userType: String
    let phoneNumber: String?
    let address: String?
    let joined: TimeInterval
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRProductModelName.id] as? String else {
            return nil
        }
        self.id = idString
        guard let name = record[HRUserModelName.name] as? String else { return nil }
        self.name = name
        guard let userType = record[HRUserModelName.userType] as? String else { return nil }
        self.userType = userType
        guard let email = record[HRUserModelName.email] as? String else { return nil }
        self.email = email
        guard let phoneNumber = record[HRUserModelName.phoneNumber] as? String else { return nil }
        self.phoneNumber = phoneNumber
        guard let address = record[HRUserModelName.address] as? String else { return nil }
        self.address = address
        guard let joined = record[HRUserModelName.joined] as? TimeInterval else { return nil }
        self.joined = joined
        self.record = record
    }
    
    init?(id: String, name: String,userType: String, email: String?, phoneNumber: String?, address: String?, joined: TimeInterval) {
        let record = CKRecord(recordType: HRUserModelName.itemRecord)
        record[HRUserModelName.id] = id
        record[HRUserModelName.name] = name
        record[HRUserModelName.userType] = userType
        record[HRUserModelName.email] = email
        record[HRUserModelName.joined] = joined
        if (phoneNumber != nil) {
            record[HRUserModelName.phoneNumber] = phoneNumber
        }
        if (address != nil) {
            record[HRUserModelName.address] = address
        }
        self.init(record: record)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userType
        case email
        case phoneNumber
        case address
        case joined
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(userType, forKey: .userType)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(joined, forKey: .joined)
    }
    
    func CKUpdatePhoneNumber(phone: String) -> HRUser? {
        let record = record
        record[HRUserModelName.phoneNumber] = phone
        return HRUser(record: record)
    }
    
    func CKUpdateAddress(address: String) -> HRUser? {
        let record = record
        record[HRUserModelName.address] = address
        return HRUser(record: record)
    }
}
