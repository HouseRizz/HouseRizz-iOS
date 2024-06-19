//
//  HRCKProduct.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import Foundation
import CloudKit

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
    static let itemRecord = "Products"
}

struct HRProduct: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let category: String
    let name: String
    let description: String?
    let supplier: String
    let address: String
    let price: Double?
    let imageURL1: URL?
    let imageURL2: URL?
    let imageURL3: URL?
    let modelURL: URL?
    let record: CKRecord

    init?(record: CKRecord) {
        guard let idString = record[HRProductModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HRProductModelName.name] as? String else { return nil }
        self.name = name
        guard let description = record[HRProductModelName.description] as? String else { return nil }
        self.description = description
        guard let category = record[HRProductModelName.category] as? String else { return nil }
        self.category = category
        guard let supplier = record[HRProductModelName.supplier] as? String else { return nil }
        self.supplier = supplier
        guard let address = record[HRProductModelName.address] as? String else { return nil }
        self.address = address
        guard let price = record[HRProductModelName.price] as? Double else { return nil }
        self.price = price
        let imageAsset1 = record[HRProductModelName.imageURL1] as? CKAsset
        self.imageURL1 = imageAsset1?.fileURL
        let imageAsset2 = record[HRProductModelName.imageURL2] as? CKAsset
        self.imageURL2 = imageAsset2?.fileURL
        let imageAsset3 = record[HRProductModelName.imageURL3] as? CKAsset
        self.imageURL3 = imageAsset3?.fileURL
        let modelURL = record[HRProductModelName.modelURL] as? CKAsset
        self.modelURL = modelURL?.fileURL
        self.record = record
    }

    init?(id: UUID, name: String, description: String?, price: Double?, imageURL1: URL?, imageURL2: URL?, imageURL3: URL?, modelURL: URL?, category: String?, supplier: String?, address: String?) {
        let record = CKRecord(recordType: HRProductModelName.itemRecord)
        record[HRProductModelName.id] = id.uuidString
        record[HRProductModelName.name] = name
        record[HRProductModelName.description] = description
        record[HRProductModelName.price] = price
        if (category != nil) {
            record[HRProductModelName.category] = category
        }
        if (supplier != nil) {
            record[HRProductModelName.supplier] = supplier
        }
        record[HRProductModelName.address] = address
        if let url1 = imageURL1 {
            let asset1 = CKAsset(fileURL: url1)
            record[HRProductModelName.imageURL1] = asset1
        }
        if let url2 = imageURL2 {
            let asset2 = CKAsset(fileURL: url2)
            record[HRProductModelName.imageURL2] = asset2
        }
        if let url3 = imageURL3 {
            let asset3 = CKAsset(fileURL: url3)
            record[HRProductModelName.imageURL3] = asset3
        }
        if let modelURL = modelURL {
            let modelAsset = CKAsset(fileURL: modelURL)
            record[HRProductModelName.modelURL] = modelAsset
        }
        self.init(record: record)
    }
}
