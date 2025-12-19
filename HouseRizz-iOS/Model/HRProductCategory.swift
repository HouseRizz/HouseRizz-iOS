//
//  HRProductCategory.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation

struct HRProductCategoryModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
}

struct HRProductCategory: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "productCategories"
    
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
