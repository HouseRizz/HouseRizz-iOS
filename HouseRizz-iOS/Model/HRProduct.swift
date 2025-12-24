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
    
    // New fields from Firestore structure
    let color: String?
    let dimensions: String?
    let materials: String?
    let keywords: [String]?
    let source: ProductSource?
    
    // Computed property for backward compatibility/ease of use
    var sourceUrl: String? {
        source?.sourceUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case id, category, name, description, supplier, address, price
        case imageURL1, imageURL2, imageURL3, modelURL
        case color, dimensions, materials, keywords, source
    }
    
    struct ProductSource: Codable, Hashable {
        let dateScraped: String?
        let sourceUrl: String?
    }
    
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
        address: String,
        color: String? = nil,
        dimensions: String? = nil,
        materials: String? = nil,
        keywords: [String]? = nil,
        source: ProductSource? = nil
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
        self.color = color
        self.dimensions = dimensions
        self.materials = materials
        self.keywords = keywords
        self.source = source
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID which might be string or UUID in Firestore
        if let idString = try? container.decode(String.self, forKey: .id),
           let uuid = UUID(uuidString: idString) {
            id = uuid
        } else {
            id = try container.decode(UUID.self, forKey: .id)
        }
        
        category = try container.decode(String.self, forKey: .category)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        supplier = try container.decode(String.self, forKey: .supplier)
        address = try container.decode(String.self, forKey: .address)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        imageURL1 = try container.decodeIfPresent(String.self, forKey: .imageURL1)
        imageURL2 = try container.decodeIfPresent(String.self, forKey: .imageURL2)
        imageURL3 = try container.decodeIfPresent(String.self, forKey: .imageURL3)
        modelURL = try container.decodeIfPresent(String.self, forKey: .modelURL)
        
        color = try container.decodeIfPresent(String.self, forKey: .color)
        dimensions = try container.decodeIfPresent(String.self, forKey: .dimensions)
        materials = try container.decodeIfPresent(String.self, forKey: .materials)
        keywords = try container.decodeIfPresent([String].self, forKey: .keywords)
        source = try container.decodeIfPresent(ProductSource.self, forKey: .source)
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
    
    var sourceURLValue: URL? {
        guard let urlString = sourceUrl else { return nil }
        return URL(string: urlString)
    }
}
