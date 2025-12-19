#!/usr/bin/env python3
"""
CloudKit to Firebase Migration Script using CloudKit Web Services API

This script automatically exports data from CloudKit using server-to-server
authentication and imports it into Firebase Firestore/Storage.

Setup:
1. Go to CloudKit Dashboard → Select your container → API Access
2. Create a new Server-to-Server Key
3. Download the private key file (.pem)
4. Note down the Key ID

Usage:
python3 cloudkit_to_firebase.py \
  --key-id YOUR_KEY_ID \
  --key-file /path/to/eckey.pem \
  --service-account /path/to/firebase-sa.json
"""

import argparse
import json
import os
import sys
import time
import base64
import hashlib
import urllib.request
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, List, Dict, Any
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.backends import default_backend

# CloudKit configuration
CLOUDKIT_CONTAINER = "iCloud.krishmittal.HouseRizz-iOS"
CLOUDKIT_ENVIRONMENT = "production"
CLOUDKIT_API_VERSION = "1"

# Record types to migrate (from CloudKit schema)
RECORD_TYPES = [
    "Products",
    "Orders",
    "ProductCategory",
    "City",
    "AddBanner",
    "AIVibe",
    "DesignImageResult",
    "API",
    "Users",
    "SignedInUsers",
    "Items"  # Legacy - may have data
]

# Collection name mapping (CloudKit → Firestore)
COLLECTION_MAPPING = {
    "Products": "products",
    "Orders": "orders",
    "ProductCategory": "productCategories",
    "City": "cities",
    "AddBanner": "addBanners",
    "AIVibe": "aiVibes",
    "DesignImageResult": "aiImageResults",
    "API": "apis",
    "Users": "users",
    "SignedInUsers": "signedInUsers",
    "Items": "items"
}


class CloudKitClient:
    """CloudKit Web Services API client with server-to-server auth"""
    
    def __init__(self, container: str, key_id: str, key_file: str, environment: str = "production"):
        self.container = container
        self.key_id = key_id
        self.environment = environment
        self.base_url = f"https://api.apple-cloudkit.com/database/{CLOUDKIT_API_VERSION}/{container}/{environment}/public"
        
        # Load private key
        with open(key_file, 'rb') as f:
            self.private_key = serialization.load_pem_private_key(
                f.read(),
                password=None,
                backend=default_backend()
            )
    
    def _sign_request(self, date: str, body: str, path: str) -> str:
        """Create ECDSA signature for request"""
        body_hash = base64.b64encode(hashlib.sha256(body.encode('utf-8')).digest()).decode('utf-8')
        message = f"{date}:{body_hash}:{path}"
        
        signature = self.private_key.sign(
            message.encode('utf-8'),
            ec.ECDSA(hashes.SHA256())
        )
        return base64.b64encode(signature).decode('utf-8')
    
    def _make_request(self, endpoint: str, data: dict) -> dict:
        """Make authenticated request to CloudKit API"""
        url = f"{self.base_url}{endpoint}"
        path = urllib.parse.urlparse(url).path
        body = json.dumps(data)
        date = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        signature = self._sign_request(date, body, path)
        
        headers = {
            'Content-Type': 'application/json',
            'X-Apple-CloudKit-Request-KeyID': self.key_id,
            'X-Apple-CloudKit-Request-ISO8601Date': date,
            'X-Apple-CloudKit-Request-SignatureV1': signature,
        }
        
        req = urllib.request.Request(url, data=body.encode('utf-8'), headers=headers, method='POST')
        
        try:
            with urllib.request.urlopen(req) as response:
                return json.loads(response.read().decode('utf-8'))
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8')
            print(f"   ❌ CloudKit API Error: {e.code}")
            print(f"      {error_body}")
            raise
    
    def query_records(self, record_type: str, continuation_marker: Optional[str] = None) -> dict:
        """Query all records of a given type"""
        data = {
            "query": {
                "recordType": record_type
            },
            "resultsLimit": 200
        }
        
        if continuation_marker:
            data["continuationMarker"] = continuation_marker
        
        return self._make_request("/records/query", data)
    
    def fetch_all_records(self, record_type: str) -> List[dict]:
        """Fetch all records of a type, handling pagination"""
        all_records = []
        continuation_marker = None
        
        while True:
            result = self.query_records(record_type, continuation_marker)
            records = result.get("records", [])
            all_records.extend(records)
            
            continuation_marker = result.get("continuationMarker")
            if not continuation_marker:
                break
        
        return all_records


class FirebaseClient:
    """Firebase Firestore and Storage client"""
    
    def __init__(self, service_account_path: str, bucket_name: str):
        from google.cloud import firestore
        from google.cloud import storage
        from google.oauth2 import service_account
        
        credentials = service_account.Credentials.from_service_account_file(service_account_path)
        self.db = firestore.Client(credentials=credentials, project=credentials.project_id)
        storage_client = storage.Client(credentials=credentials, project=credentials.project_id)
        self.bucket = storage_client.bucket(bucket_name)
    
    def upload_asset(self, url: str, record_name: str, field_name: str) -> str:
        """Download asset from CloudKit and upload to Firebase Storage"""
        try:
            with urllib.request.urlopen(url) as response:
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
            
            blob_path = f"migrated/{record_name}/{field_name}.{ext}"
            blob = self.bucket.blob(blob_path)
            blob.upload_from_string(data)
            blob.make_public()
            
            return blob.public_url
        except Exception as e:
            print(f"      ⚠️ Failed to upload asset: {e}")
            return url
    
    def import_record(self, record: dict, collection_name: str, dry_run: bool):
        """Import a CloudKit record into Firestore"""
        record_name = record.get("recordName", "")
        fields = record.get("fields", {})
        
        doc_data = {"id": record_name}
        
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
                download_url = value.get("downloadURL", "")
                if download_url and not dry_run:
                    doc_data[field_name] = self.upload_asset(download_url, record_name, field_name)
                else:
                    doc_data[field_name] = download_url
            elif value_type == "REFERENCE":
                doc_data[field_name] = value.get("recordName", "")
            else:
                doc_data[field_name] = value
        
        if dry_run:
            print(f"      [DRY RUN] Would create: {collection_name}/{record_name}")
        else:
            self.db.collection(collection_name).document(record_name).set(doc_data)
            print(f"      ✅ Created: {collection_name}/{record_name}")


def main():
    parser = argparse.ArgumentParser(description="Migrate CloudKit to Firebase")
    parser.add_argument("--key-id", required=True, help="CloudKit Server-to-Server Key ID")
    parser.add_argument("--key-file", required=True, help="Path to CloudKit private key (.pem)")
    parser.add_argument("--service-account", required=True, help="Path to Firebase service account JSON")
    parser.add_argument("--bucket", default="houserizz-481012.appspot.com", help="Firebase Storage bucket")
    parser.add_argument("--dry-run", action="store_true", help="Preview without making changes")
    args = parser.parse_args()
    
    print("🚀 CloudKit to Firebase Migration")
    print("==================================")
    print(f"📦 Container: {CLOUDKIT_CONTAINER}")
    print(f"🔑 Key ID: {args.key_id}")
    print(f"🔄 Dry Run: {args.dry_run}")
    print()
    
    # Initialize clients
    print("🔧 Initializing CloudKit client...")
    ck = CloudKitClient(CLOUDKIT_CONTAINER, args.key_id, args.key_file, CLOUDKIT_ENVIRONMENT)
    
    print("🔧 Initializing Firebase client...")
    fb = FirebaseClient(args.service_account, args.bucket)
    
    print("✅ Clients initialized\n")
    
    # Migrate each record type
    for record_type in RECORD_TYPES:
        collection_name = COLLECTION_MAPPING.get(record_type, record_type.lower())
        print(f"📋 Migrating {record_type} → {collection_name}...")
        
        try:
            records = ck.fetch_all_records(record_type)
            print(f"   Found {len(records)} records")
            
            for record in records:
                fb.import_record(record, collection_name, args.dry_run)
            
            print(f"   ✅ Migrated {len(records)} records\n")
        except Exception as e:
            print(f"   ❌ Error: {e}\n")
    
    print("🎉 Migration complete!")


if __name__ == "__main__":
    main()
