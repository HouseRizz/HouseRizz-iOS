import Foundation
import CloudKit
import ArgumentParser

@main
struct MigrationTool: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Migrate data from CloudKit to Firebase",
        discussion: "Exports all records from CloudKit container and imports them into Firestore with assets uploaded to Firebase Storage."
    )
    
    @Option(name: .long, help: "Path to GCP service account JSON file")
    var serviceAccount: String
    
    @Flag(name: .long, help: "Perform dry run without actually uploading")
    var dryRun: Bool = false
    
    func run() async throws {
        print("🚀 CloudKit to Firebase Migration Tool")
        print("=====================================")
        
        // Validate service account file exists
        guard FileManager.default.fileExists(atPath: serviceAccount) else {
            print("❌ Service account file not found: \(serviceAccount)")
            throw ExitCode.failure
        }
        
        print("✅ Service account: \(serviceAccount)")
        print("📦 CloudKit Container: iCloud.krishmittal.HouseRizz-iOS")
        print("🔄 Dry Run: \(dryRun)")
        print("")
        
        // Initialize CloudKit
        let container = CKContainer(identifier: "iCloud.krishmittal.HouseRizz-iOS")
        let database = container.publicCloudDatabase
        
        // Check iCloud status
        print("🔍 Checking iCloud status...")
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                print("✅ iCloud account available")
            case .noAccount:
                print("❌ No iCloud account. Please sign in to iCloud in System Preferences.")
                throw ExitCode.failure
            case .restricted:
                print("❌ iCloud account restricted")
                throw ExitCode.failure
            case .couldNotDetermine:
                print("❌ Could not determine iCloud status")
                throw ExitCode.failure
            case .temporarilyUnavailable:
                print("⚠️ iCloud temporarily unavailable, will retry...")
            @unknown default:
                print("❌ Unknown iCloud status")
                throw ExitCode.failure
            }
        } catch {
            print("❌ Error checking iCloud status: \(error.localizedDescription)")
            throw ExitCode.failure
        }
        
        // Initialize Firebase
        let firebaseImporter = FirebaseImporter(serviceAccountPath: serviceAccount, dryRun: dryRun)
        try await firebaseImporter.initialize()
        
        // Initialize CloudKit exporter
        let exporter = CloudKitExporter(database: database)
        
        // Migrate each record type
        let recordTypes = [
            "HRProduct",
            "HROrder", 
            "HRProductCategory",
            "HRCity",
            "HRAddBanner",
            "HRAIVibe",
            "HRAIImageResult",
            "HRAPI"
        ]
        
        for recordType in recordTypes {
            print("\n📋 Migrating \(recordType)...")
            do {
                let records = try await exporter.fetchAllRecords(ofType: recordType)
                print("   Found \(records.count) records")
                
                for record in records {
                    try await firebaseImporter.importRecord(record, ofType: recordType)
                }
                
                print("   ✅ Migrated \(records.count) \(recordType) records")
            } catch {
                print("   ❌ Error migrating \(recordType): \(error.localizedDescription)")
            }
        }
        
        print("\n🎉 Migration complete!")
    }
}
