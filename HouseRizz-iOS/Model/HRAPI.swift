//
//  HRAPI.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 20/06/24.
//

import Foundation
import CloudKit

struct HRAPIModelName {
    static let id = "id"
    static let name = "name"
    static let api = "api"
    static let itemRecord = "API"
}

struct HRAPI: Hashable, Identifiable, CKitableProtocol {
    var id: UUID
    let name: String
    let api: String
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let idString = record[HRAPIModelName.id] as? String, let id = UUID(uuidString: idString) else {
            return nil
        }
        self.id = id
        guard let name = record[HRAPIModelName.name] as? String else { return nil }
        self.name = name
        guard let api = record[HRAPIModelName.api] as? String else { return nil }
        self.api = api
        self.record = record
    }
    
    init?(id: UUID, name: String, api: String) {
        let record = CKRecord(recordType: HRAPIModelName.itemRecord)
        record[HRAPIModelName.id] = id.uuidString
        record[HRAPIModelName.name] = name
        record[HRAPIModelName.api] = api
        self.init(record: record)
    }
}
