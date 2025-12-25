//
//  HRAIRoomType.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 25/12/24.
//

import Foundation

struct HRAIRoomTypeModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
}

struct HRAIRoomType: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "aiRoomTypes"
    
    var id: UUID
    let name: String
    let imageURL: String?
    
    init(id: UUID = UUID(), name: String, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
    
    /// Convenience computed property to get URL from string
    var imageURLValue: URL? {
        guard let urlString = imageURL else { return nil }
        return URL(string: urlString)
    }
}
