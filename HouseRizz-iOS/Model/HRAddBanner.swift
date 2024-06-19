//
//  HRAddBanner.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import CloudKit

struct HRAddBannerModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
    static let sliderNumber = "sliderNumber"
    static let itemRecord = "AddBanner"
}

struct HRAddBanner: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let name: String
    let imageURL: URL?
    let sliderNumber: Int
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRAddBannerModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HRAddBannerModelName.name] as? String else { return nil }
        self.name = name
        let imageAsset = record[HRAddBannerModelName.imageURL] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        guard let sliderNumber = record[HRAddBannerModelName.sliderNumber] as? Int else { return nil }
        self.sliderNumber = sliderNumber
        self.record = record
    }
    
    init?(id: UUID, name: String, imageURL: URL?, sliderNumber: Int) {
        let record = CKRecord(recordType: HRAddBannerModelName.itemRecord)
        record[HRAddBannerModelName.id] = id.uuidString
        record[HRAddBannerModelName.name] = name
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record[HRAddBannerModelName.imageURL] = asset
        }
        record[HRAddBannerModelName.sliderNumber] = sliderNumber
        self.init(record: record)
    }
}
