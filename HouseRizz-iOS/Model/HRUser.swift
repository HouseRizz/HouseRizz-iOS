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
    static let userFirestore = "users_prod"
}

struct HRUser: Encodable, Hashable, Identifiable {
    let id: String
    let name: String
    let email: String
    let userType: String
    let phoneNumber: String?
    let address: String?
    let joined: TimeInterval
}
