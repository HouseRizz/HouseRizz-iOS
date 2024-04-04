//
//  HRUser.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import Foundation

struct HRUser: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
