//
//  HRCKProduct.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/05/24.
//

import Foundation
import CloudKit

struct CKItemModelName {
    static let name = "name"
    static let description = "description"
    static let category = "category"
    static let supplier = "supplier"
    static let price = "price"
    static let imageURL1 = "imageURL1"
    static let imageURL2 = "imageURL2"
    static let imageURL3 = "imageURL3"
    static let modelURL = "modelURL"
    static let itemRecord = "Items"
}

struct HRCKProduct: Hashable, CKitableProtocol {
    let category: String
    let name: String
    let description: String?
    let supplier: String
    let price: Int?
    let imageURL1: URL?
    let imageURL2: URL?
    let imageURL3: URL?
    let modelURL: URL?
    let record: CKRecord
    
    init?(record: CKRecord){
        guard let name = record[CKItemModelName.name] as? String else {return nil}
        self.name = name
        guard let description = record[CKItemModelName.description] as? String else {return nil}
        self.description = description
        guard let category = record[CKItemModelName.category] as? String else {return nil}
        self.category = category
        guard let supplier = record[CKItemModelName.supplier] as? String else {return nil}
        self.supplier = supplier
        guard let price = record[CKItemModelName.price] as? Int else {return nil}
        self.price = price
        let imageAsset1 = record[CKItemModelName.imageURL1] as? CKAsset
        self.imageURL1 = imageAsset1?.fileURL
        let imageAsset2 = record[CKItemModelName.imageURL2] as? CKAsset
        self.imageURL2 = imageAsset2?.fileURL
        let imageAsset3 = record[CKItemModelName.imageURL3] as? CKAsset
        self.imageURL3 = imageAsset3?.fileURL
        let modelURL = record[CKItemModelName.modelURL] as? CKAsset
        self.modelURL = modelURL?.fileURL
        self.record = record
    }
    
    init?(name: String, description: String?, price: Int?, imageURL1: URL?, imageURL2: URL?, imageURL3: URL?,  modelURL: URL?, category: String?, supplier: String?) {
        let record = CKRecord(recordType: CKItemModelName.itemRecord)
        record[CKItemModelName.name] = name
        record[CKItemModelName.description] = description
        record[CKItemModelName.price] = price
        if (category != nil) {
            record[CKItemModelName.category] = category
        }
        if (supplier != nil) {
            record[CKItemModelName.supplier] = supplier
        }
        if let url1 = imageURL1 {
            let asset1 = CKAsset(fileURL: url1)
            record[CKItemModelName.imageURL1] = asset1
        }
        if let url2 = imageURL2 {
            let asset2 = CKAsset(fileURL: url2)
            record[CKItemModelName.imageURL2] = asset2
        }
        if let url3 = imageURL3 {
            let asset3 = CKAsset(fileURL: url3)
            record[CKItemModelName.imageURL3] = asset3
        }
        if let modelURL = modelURL {
            let modelAsset = CKAsset(fileURL: modelURL)
            record[CKItemModelName.modelURL] = modelAsset
        }
        self.init(record: record)
    }
}
