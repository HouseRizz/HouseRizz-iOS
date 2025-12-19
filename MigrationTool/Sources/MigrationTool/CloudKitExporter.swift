import Foundation
import CloudKit

/// Exports records from CloudKit
class CloudKitExporter {
    let database: CKDatabase
    
    init(database: CKDatabase) {
        self.database = database
    }
    
    /// Fetch all records of a given type from CloudKit
    func fetchAllRecords(ofType recordType: String) async throws -> [CKRecord] {
        var allRecords: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor? = nil
        
        repeat {
            let (records, nextCursor) = try await fetchBatch(ofType: recordType, cursor: cursor)
            allRecords.append(contentsOf: records)
            cursor = nextCursor
        } while cursor != nil
        
        return allRecords
    }
    
    private func fetchBatch(ofType recordType: String, cursor: CKQueryOperation.Cursor?) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        return try await withCheckedThrowingContinuation { continuation in
            var fetchedRecords: [CKRecord] = []
            
            let operation: CKQueryOperation
            if let cursor = cursor {
                operation = CKQueryOperation(cursor: cursor)
            } else {
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                operation = CKQueryOperation(query: query)
            }
            
            operation.resultsLimit = 100
            
            operation.recordMatchedBlock = { recordID, result in
                switch result {
                case .success(let record):
                    fetchedRecords.append(record)
                case .failure(let error):
                    print("      ⚠️ Failed to fetch record \(recordID.recordName): \(error.localizedDescription)")
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case .success(let cursor):
                    continuation.resume(returning: (fetchedRecords, cursor))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            database.add(operation)
        }
    }
    
    /// Download asset data from CKAsset
    func downloadAsset(_ asset: CKAsset) async throws -> Data {
        guard let fileURL = asset.fileURL else {
            throw MigrationError.assetNotFound
        }
        return try Data(contentsOf: fileURL)
    }
}

enum MigrationError: LocalizedError {
    case assetNotFound
    case uploadFailed
    case invalidRecord
    
    var errorDescription: String? {
        switch self {
        case .assetNotFound:
            return "Asset file not found"
        case .uploadFailed:
            return "Failed to upload to Firebase"
        case .invalidRecord:
            return "Invalid record format"
        }
    }
}
