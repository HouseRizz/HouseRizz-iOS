//
//  HRProductCategory.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 19/06/24.
//

import Foundation
import CloudKit

struct HRProductCategoryModelName {
    static let id = "id"
    static let name = "name"
    static let imageURL = "imageURL"
    static let itemRecord = "ProductCategory"
}

struct HRProductCategory: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let name: String
    let imageURL: URL?
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRProductCategoryModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HRProductCategoryModelName.name] as? String else { return nil }
        self.name = name
        let imageAsset = record[HRProductCategoryModelName.imageURL] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        self.record = record
    }
    
    init?(id: UUID, name: String, imageURL: URL?) {
        let record = CKRecord(recordType: HRProductCategoryModelName.itemRecord)
        record[HRProductCategoryModelName.id] = id.uuidString
        record[HRProductCategoryModelName.name] = name
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record[HRProductCategoryModelName.imageURL] = asset
        }
        self.init(record: record)
    }
}
