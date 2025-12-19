//
//  HRAPI.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import Foundation

struct HRAPIModelName {
    static let id = "id"
    static let name = "name"
    static let api = "api"
}

struct HRAPI: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "apis"
    
    var id: UUID
    let name: String
    let api: String
    
    init(id: UUID = UUID(), name: String, api: String) {
        self.id = id
        self.name = name
        self.api = api
    }
}
