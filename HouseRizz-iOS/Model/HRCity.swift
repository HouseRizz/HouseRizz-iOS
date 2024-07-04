//
//  HRCity.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/07/24.
//

import Foundation
import CloudKit

struct HRCityModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
    static let itemRecord = "City"
}

struct HRCity: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let name: String
    let imageURL: URL?
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRCityModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HRCityModelName.name] as? String else { return nil }
        self.name = name
        let imageAsset = record[HRCityModelName.imageURL] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        self.record = record
    }
    
    init?(id: UUID, name: String, imageURL: URL?) {
        let record = CKRecord(recordType: HRCityModelName.itemRecord)
        record[HRCityModelName.id] = id.uuidString
        record[HRCityModelName.name] = name
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record[HRCityModelName.imageURL] = asset
        }
        self.init(record: record)
    }
}
