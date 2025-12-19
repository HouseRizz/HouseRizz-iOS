#!/usr/bin/env python3
"""
CloudKit to Firebase Migration Script

This script imports data exported from CloudKit Dashboard into Firebase Firestore
and uploads assets to Firebase Storage.

Usage:
1. Export records from CloudKit Dashboard (https://icloud.developer.apple.com/)
2. Save the exported JSON files in a folder
3. Run: python3 import_to_firebase.py --data-dir ./cloudkit_export --service-account ./service-account.json
"""

import argparse
import json
import os
import sys
import base64
from pathlib import Path
from datetime import datetime
from google.cloud import firestore
from google.cloud import storage
from google.oauth2 import service_account

# Collection name mapping
COLLECTION_MAPPING = {
    "HRProduct": "products",
    "HROrder": "orders",
    "HRProductCategory": "productCategories",
    "HRCity": "cities",
    "HRAddBanner": "addBanners",
    "HRAIVibe": "aiVibes",
    "HRAIImageResult": "aiImageResults",
    "HRAPI": "apis"
}

def parse_args():
    parser = argparse.ArgumentParser(description="Import CloudKit data to Firebase")
    parser.add_argument("--data-dir", required=True, help="Directory containing CloudKit exported JSON files")
    parser.add_argument("--service-account", required=True, help="Path to GCP service account JSON")
    parser.add_argument("--bucket", default="houserizz-481012.appspot.com", help="Firebase Storage bucket")
    parser.add_argument("--dry-run", action="store_true", help="Preview without uploading")
    return parser.parse_args()

def init_firebase(service_account_path: str, bucket_name: str):
    """Initialize Firebase clients"""
    credentials = service_account.Credentials.from_service_account_file(service_account_path)
    db = firestore.Client(credentials=credentials, project=credentials.project_id)
    storage_client = storage.Client(credentials=credentials, project=credentials.project_id)
    bucket = storage_client.bucket(bucket_name)
    return db, bucket

def convert_cloudkit_record(record: dict, bucket, dry_run: bool) -> dict:
    """Convert CloudKit record format to Firestore document format"""
    fields = record.get("fields", {})
    doc_data = {
        "id": record.get("recordName", "")
    }
    
    for field_name, field_value in fields.items():
        value_type = field_value.get("type", "")
        value = field_value.get("value")
        
        if value_type == "STRING":
            doc_data[field_name] = value
        elif value_type == "INT64":
            doc_data[field_name] = int(value)
        elif value_type == "DOUBLE":
            doc_data[field_name] = float(value)
        elif value_type == "TIMESTAMP":
            doc_data[field_name] = datetime.fromtimestamp(value / 1000)
        elif value_type == "ASSET":
            # Handle asset upload
            asset_url = upload_asset(value, record.get("recordName", ""), field_name, bucket, dry_run)
            doc_data[field_name] = asset_url
        elif value_type == "REFERENCE":
            doc_data[field_name] = value.get("recordName", "")
        elif value_type == "LOCATION":
            doc_data[field_name] = {
                "latitude": value.get("latitude"),
                "longitude": value.get("longitude")
            }
        else:
            doc_data[field_name] = value
    
    return doc_data

def upload_asset(asset_info: dict, record_id: str, field_name: str, bucket, dry_run: bool) -> str:
    """Upload asset to Firebase Storage and return download URL"""
    download_url = asset_info.get("downloadURL")
    
    if dry_run:
        print(f"      [DRY RUN] Would upload asset: {field_name} from {download_url[:50]}...")
        return download_url or ""
    
    if not download_url:
        print(f"      ⚠️ No download URL for asset {field_name}")
        return ""
    
    try:
        import urllib.request
        
        # Download asset
        with urllib.request.urlopen(download_url) as response:
            data = response.read()
        
        # Detect file extension
        ext = "bin"
        if len(data) >= 4:
            if data[:3] == b'\xff\xd8\xff':
                ext = "jpg"
            elif data[:4] == b'\x89PNG':
                ext = "png"
            elif data[:4] == b'PK\x03\x04':
                ext = "usdz"
        
        # Upload to Firebase Storage
        blob_path = f"migrated/{record_id}/{field_name}.{ext}"
        blob = bucket.blob(blob_path)
        blob.upload_from_string(data)
        blob.make_public()
        
        print(f"      📤 Uploaded: {blob_path}")
        return blob.public_url
    except Exception as e:
        print(f"      ⚠️ Failed to upload asset {field_name}: {e}")
        return download_url or ""

def import_records(json_file: Path, db, bucket, dry_run: bool):
    """Import records from a JSON file"""
    print(f"\n📂 Processing: {json_file.name}")
    
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    records = data.get("records", [])
    if not records:
        print("   No records found")
        return
    
    # Determine record type from first record
    record_type = records[0].get("recordType", "Unknown")
    collection_name = COLLECTION_MAPPING.get(record_type, record_type.lower())
    
    print(f"   Record type: {record_type} → Collection: {collection_name}")
    print(f"   Found {len(records)} records")
    
    for record in records:
        record_name = record.get("recordName", "unknown")
        try:
            doc_data = convert_cloudkit_record(record, bucket, dry_run)
            
            if dry_run:
                print(f"   [DRY RUN] Would create: {collection_name}/{record_name}")
            else:
                db.collection(collection_name).document(record_name).set(doc_data)
                print(f"   ✅ Created: {collection_name}/{record_name}")
        except Exception as e:
            print(f"   ❌ Error processing {record_name}: {e}")
    
    print(f"   ✅ Processed {len(records)} {record_type} records")

def main():
    args = parse_args()
    
    print("🚀 CloudKit to Firebase Import Script")
    print("=====================================")
    print(f"📁 Data directory: {args.data_dir}")
    print(f"🔑 Service account: {args.service_account}")
    print(f"🪣 Storage bucket: {args.bucket}")
    print(f"🔄 Dry run: {args.dry_run}")
    print()
    
    # Validate paths
    data_dir = Path(args.data_dir)
    if not data_dir.exists():
        print(f"❌ Data directory not found: {args.data_dir}")
        sys.exit(1)
    
    if not os.path.exists(args.service_account):
        print(f"❌ Service account file not found: {args.service_account}")
        sys.exit(1)
    
    # Initialize Firebase
    print("🔧 Initializing Firebase...")
    db, bucket = init_firebase(args.service_account, args.bucket)
    print("✅ Firebase initialized")
    
    # Find all JSON files
    json_files = list(data_dir.glob("*.json"))
    if not json_files:
        print(f"❌ No JSON files found in {args.data_dir}")
        sys.exit(1)
    
    print(f"\n📋 Found {len(json_files)} JSON files to import")
    
    # Import each file
    for json_file in json_files:
        import_records(json_file, db, bucket, args.dry_run)
    
    print("\n🎉 Import complete!")

if __name__ == "__main__":
    main()
