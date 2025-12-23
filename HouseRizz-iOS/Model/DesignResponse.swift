//
//  DesignResponse.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/12/24.
//

import Foundation
import CoreGraphics

/// Response model for the Virtual Staging API /design/upload endpoint
struct DesignResponse: Codable {
    let success: Bool
    let generatedImageURL: String
    let furnitureUsed: [FurnitureUsed]?
    let vibe: String
    let segmentation: SegmentationData?
    let matchedLabels: [String]?
    let furnitureMarkers: [FurnitureMarker]?  // Furniture with position for overlay
    
    enum CodingKeys: String, CodingKey {
        case success
        case generatedImageURL = "generated_image_url"
        case furnitureUsed = "furniture_used"
        case vibe
        case segmentation
        case matchedLabels = "matched_labels"
        case furnitureMarkers = "furniture_markers"
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

/// Furniture marker with position data from API for interactive overlay
struct FurnitureMarker: Codable, Identifiable, Hashable {
    var id: String { "\(name)_\(type)" }
    
    let name: String
    let type: String
    let price: Double?
    let imageURL: String?
    let description: String?
    /// Bounding box in normalized coordinates (0-1): [x1, y1, x2, y2]
    let box: [Double]
    /// Mask color [R, G, B] for highlight effect
    let maskColor: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case price
        case imageURL = "image_url"
        case description
        case box
        case maskColor = "mask_color"
    }
    
    /// Center point of the bounding box (normalized 0-1)
    var centerPoint: CGPoint {
        guard box.count >= 4 else { return .zero }
        let centerX = (box[0] + box[2]) / 2
        let centerY = (box[1] + box[3]) / 2
        return CGPoint(x: centerX, y: centerY)
    }
    
    /// Formatted price string
    var formattedPrice: String? {
        guard let price = price else { return nil }
        return String(format: "$%.0f", price)
    }
}
