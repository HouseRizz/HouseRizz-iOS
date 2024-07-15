//
//  HRAIImageResult.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 21/06/24.
//

import Foundation
import CloudKit

struct HRAIImageResultModelName {
    static let id = "id"
    static let userName = "userName"
    static let imageURL = "imageURL"
    static let vibe = "vibe"
    static let type = "type"
    static let created = "created"
    static let record = "record"
    static let itemRecord = "DesignImageResult"
}

struct HRAIImageResult: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let userName: String
    let imageURL: String?
    let vibe: String
    let type: String
    let created: TimeInterval
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRAIImageResultModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let userName = record[HRAIImageResultModelName.userName] as? String else { return nil }
        self.userName = userName
        guard let imageURL = record[HRAIImageResultModelName.imageURL] as? String else { return nil }
        self.imageURL = imageURL
        guard let vibe = record[HRAIImageResultModelName.vibe] as? String else { return nil }
        self.vibe = vibe
        guard let type = record[HRAIImageResultModelName.type] as? String else { return nil }
        self.type = type
        guard let created = record[HRAIImageResultModelName.created] as? TimeInterval else { return nil }
        self.created = created
        self.record = record
    }
    
    init?(id: UUID, userName: String, imageURL: String, vibe: String, type: String, created: TimeInterval) {
        let record = CKRecord(recordType: HRAIImageResultModelName.itemRecord)
        record[HRAIImageResultModelName.id] = id.uuidString
        record[HRAIImageResultModelName.userName] = userName
        record[HRAIImageResultModelName.imageURL] = imageURL
        record[HRAIImageResultModelName.vibe] = vibe
        record[HRAIImageResultModelName.type] = type
        record[HRAIImageResultModelName.created] = created
        self.init(record: record)
    }
}
