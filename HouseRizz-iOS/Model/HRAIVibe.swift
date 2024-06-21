//
//  HRAIVibe.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import Foundation
import CloudKit

struct HRAIVibeModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
    static let itemRecord = "ProductCategory"
}

struct HRAIVibe: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let name: String
    let imageURL: URL?
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRAIVibeModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HRAIVibeModelName.name] as? String else { return nil }
        self.name = name
        let imageAsset = record[HRAIVibeModelName.imageURL] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        self.record = record
    }
    
    init?(id: UUID, name: String, imageURL: URL?) {
        let record = CKRecord(recordType: HRAIVibeModelName.itemRecord)
        record[HRAIVibeModelName.id] = id.uuidString
        record[HRAIVibeModelName.name] = name
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record[HRAIVibeModelName.imageURL] = asset
        }
        self.init(record: record)
    }
}
