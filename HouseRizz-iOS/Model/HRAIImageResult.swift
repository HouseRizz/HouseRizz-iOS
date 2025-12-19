//
//  HRAIImageResult.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import Foundation

struct HRAIImageResultModelName {
    static let id = "id"
    static let userName = "userName"
    static let imageURL = "imageURL"
    static let vibe = "vibe"
    static let type = "type"
    static let created = "created"
}

struct HRAIImageResult: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "designImageResults"
    
    var id: UUID
    let userName: String
    let imageURL: String?
    let vibe: String
    let type: String
    let created: TimeInterval
    
    init(id: UUID = UUID(), userName: String, imageURL: String?, vibe: String, type: String, created: TimeInterval = Date().timeIntervalSince1970) {
        self.id = id
        self.userName = userName
        self.imageURL = imageURL
        self.vibe = vibe
        self.type = type
        self.created = created
    }
    
    /// Convenience computed property to get URL from string
    var imageURLValue: URL? {
        guard let urlString = imageURL else { return nil }
        return URL(string: urlString)
    }
}
