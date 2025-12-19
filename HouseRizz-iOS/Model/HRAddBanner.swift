//
//  HRAddBanner.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation

struct HRAddBannerModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
    static let sliderNumber = "sliderNumber"
}

struct HRAddBanner: Hashable, Identifiable, Codable, FirestorableProtocol {
    static let collectionName = "banners"
    
    var id: UUID
    let name: String
    let imageURL: String?
    let sliderNumber: Int
    
    init(id: UUID = UUID(), name: String, imageURL: String? = nil, sliderNumber: Int) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.sliderNumber = sliderNumber
    }
    
    /// Convenience computed property to get URL from string
    var imageURLValue: URL? {
        guard let urlString = imageURL else { return nil }
        return URL(string: urlString)
    }
}
