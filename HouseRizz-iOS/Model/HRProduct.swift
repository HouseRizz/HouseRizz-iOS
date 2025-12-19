//
//  HRProduct.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import Foundation

struct HRProductModelName {
    static let id = "id"
    static let name = "name"
    static let description = "description"
    static let category = "category"
    static let supplier = "supplier"
    static let address = "address"
    static let price = "price"
    static let imageURL1 = "imageURL1"
    static let imageURL2 = "imageURL2"
    static let imageURL3 = "imageURL3"
    static let modelURL = "modelURL"
}

struct HRProduct: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "products"
    
    var id: UUID
    let category: String
    let name: String
    let description: String?
    let supplier: String
    let address: String
    let price: Double?
    let imageURL1: String?
    let imageURL2: String?
    let imageURL3: String?
    let modelURL: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        price: Double? = nil,
        imageURL1: String? = nil,
        imageURL2: String? = nil,
        imageURL3: String? = nil,
        modelURL: String? = nil,
        category: String,
        supplier: String,
        address: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL1 = imageURL1
        self.imageURL2 = imageURL2
        self.imageURL3 = imageURL3
        self.modelURL = modelURL
        self.category = category
        self.supplier = supplier
        self.address = address
    }
    
    /// Convenience computed properties to get URLs from strings
    var imageURL1Value: URL? {
        guard let urlString = imageURL1 else { return nil }
        return URL(string: urlString)
    }
    
    var imageURL2Value: URL? {
        guard let urlString = imageURL2 else { return nil }
        return URL(string: urlString)
    }
    
    var imageURL3Value: URL? {
        guard let urlString = imageURL3 else { return nil }
        return URL(string: urlString)
    }
    
    var modelURLValue: URL? {
        guard let urlString = modelURL else { return nil }
        return URL(string: urlString)
    }
}
