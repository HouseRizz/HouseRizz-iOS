import Foundation
import CloudKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

/// Imports records into Firebase Firestore and Storage
class FirebaseImporter {
    let serviceAccountPath: String
    let dryRun: Bool
    var db: Firestore!
    var storage: Storage!
    
    init(serviceAccountPath: String, dryRun: Bool) {
        self.serviceAccountPath = serviceAccountPath
        self.dryRun = dryRun
    }
    
    func initialize() async throws {
        print("🔧 Initializing Firebase...")
        
        // Configure Firebase with service account
        let options = FirebaseOptions(
            googleAppID: "1:986776132088:ios:placeholder",
            gcmSenderID: "986776132088"
        )
        options.projectID = "houserizz-481012"
        options.storageBucket = "houserizz-481012.appspot.com"
        
        FirebaseApp.configure(options: options)
        
        db = Firestore.firestore()
        storage = Storage.storage()
        
        print("✅ Firebase initialized")
    }
    
    /// Import a CloudKit record into Firestore
    func importRecord(_ record: CKRecord, ofType recordType: String) async throws {
        let collectionName = mapRecordTypeToCollection(recordType)
        let recordID = record.recordID.recordName
        
        // Convert CKRecord to dictionary
        var data = try await convertRecord(record, ofType: recordType)
        
        // Use the record ID as document ID
        data["id"] = recordID
        
        if dryRun {
            print("      [DRY RUN] Would create document: \(collectionName)/\(recordID)")
            return
        }
        
        // Create Firestore document
        try await db.collection(collectionName).document(recordID).setData(data)
        print("      Created: \(collectionName)/\(recordID)")
    }
    
    private func mapRecordTypeToCollection(_ recordType: String) -> String {
        switch recordType {
        case "HRProduct": return "products"
        case "HROrder": return "orders"
        case "HRProductCategory": return "productCategories"
        case "HRCity": return "cities"
        case "HRAddBanner": return "addBanners"
        case "HRAIVibe": return "aiVibes"
        case "HRAIImageResult": return "aiImageResults"
        case "HRAPI": return "apis"
        default: return recordType.lowercased()
        }
    }
    
    private func convertRecord(_ record: CKRecord, ofType recordType: String) async throws -> [String: Any] {
        var data: [String: Any] = [:]
        
        for key in record.allKeys() {
            if let value = record[key] {
                if let asset = value as? CKAsset {
                    // Upload asset to Firebase Storage
                    if let url = try await uploadAsset(asset, recordID: record.recordID.recordName, fieldName: key) {
                        data[key] = url
                    }
                } else if let reference = value as? CKRecord.Reference {
                    data[key] = reference.recordID.recordName
                } else if let date = value as? Date {
                    data[key] = Timestamp(date: date)
                } else if let location = value as? CLLocation {
                    data[key] = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                } else {
                    data[key] = value
                }
            }
        }
        
        return data
    }
    
    private func uploadAsset(_ asset: CKAsset, recordID: String, fieldName: String) async throws -> String? {
        guard let fileURL = asset.fileURL else {
            print("      ⚠️ No file URL for asset \(fieldName)")
            return nil
        }
        
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            print("      ⚠️ Could not read asset file: \(error.localizedDescription)")
            return nil
        }
        
        // Determine file extension from UTI or use jpg as default
        let fileExtension = detectFileExtension(from: data)
        let storagePath = "migrated/\(recordID)/\(fieldName).\(fileExtension)"
        
        if dryRun {
            print("      [DRY RUN] Would upload asset: \(storagePath) (\(data.count) bytes)")
            return "gs://houserizz-481012.appspot.com/\(storagePath)"
        }
        
        // Upload to Firebase Storage
        let storageRef = storage.reference().child(storagePath)
        let metadata = StorageMetadata()
        metadata.contentType = detectContentType(from: data)
        
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        print("      📤 Uploaded: \(storagePath)")
        return downloadURL.absoluteString
    }
    
    private func detectFileExtension(from data: Data) -> String {
        // Check magic bytes
        if data.count >= 4 {
            let bytes = [UInt8](data.prefix(4))
            
            // JPEG: FF D8 FF
            if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
                return "jpg"
            }
            // PNG: 89 50 4E 47
            if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
                return "png"
            }
            // USDZ/ZIP: 50 4B 03 04
            if bytes[0] == 0x50 && bytes[1] == 0x4B && bytes[2] == 0x03 && bytes[3] == 0x04 {
                return "usdz"
            }
        }
        return "bin"
    }
    
    private func detectContentType(from data: Data) -> String {
        let ext = detectFileExtension(from: data)
        switch ext {
        case "jpg": return "image/jpeg"
        case "png": return "image/png"
        case "usdz": return "model/vnd.usdz+zip"
        default: return "application/octet-stream"
        }
    }
}
