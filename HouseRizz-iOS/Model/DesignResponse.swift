//
//  DesignResponse.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/12/24.
//

import Foundation

/// Response model for the Virtual Staging API /design/upload endpoint
struct DesignResponse: Codable {
    let success: Bool
    let generatedImageURL: String
    let furnitureUsed: [FurnitureUsed]?
    let vibe: String
    let segmentation: SegmentationData?
    let matchedLabels: [String]?  // Segmentation labels that match furniture_used items
    
    enum CodingKeys: String, CodingKey {
        case success
        case generatedImageURL = "generated_image_url"
        case furnitureUsed = "furniture_used"
        case vibe
        case segmentation
        case matchedLabels = "matched_labels"
    }
}

/// Furniture item returned from the Virtual Staging API
struct FurnitureUsed: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let type: String?
    let imageURL: String?
    let price: Double?
    let searchedFor: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case imageURL = "image_url"
        case price
        case searchedFor = "searched_for"
    }
}

/// Segmentation response from RAM-Grounded-SAM
struct SegmentationData: Codable {
    let maskedImg: String
    let visualizationImg: String
    let tags: String
    let objects: [SegmentedObject]
    
    enum CodingKeys: String, CodingKey {
        case maskedImg = "masked_img"
        case visualizationImg = "visualization_img"
        case tags
        case objects
    }
}

/// A detected object with bounding box from segmentation
struct SegmentedObject: Codable, Identifiable, Hashable {
    var id: String { "\(label)_\(value)" }
    let label: String
    let box: [Double]  // [x1, y1, x2, y2]
    let confidence: Double
    let value: Int
    
    enum CodingKeys: String, CodingKey {
        case label
        case box
        case confidence
        case value
    }
}

/// Request model for the Virtual Staging API
struct DesignRequest: Codable {
    let roomImageBase64: String
    let mimeType: String
    let vibeText: String
    let runSegmentation: Bool
    
    enum CodingKeys: String, CodingKey {
        case roomImageBase64 = "room_image_base64"
        case mimeType = "mime_type"
        case vibeText = "vibe_text"
        case runSegmentation = "run_segmentation"
    }
    
    init(roomImageBase64: String, mimeType: String, vibeText: String, runSegmentation: Bool = true) {
        self.roomImageBase64 = roomImageBase64
        self.mimeType = mimeType
        self.vibeText = vibeText
        self.runSegmentation = runSegmentation
    }
}
