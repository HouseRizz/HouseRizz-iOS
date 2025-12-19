#!/usr/bin/env python3
"""
Asset Migration Script - Downloads assets from CloudKit and uploads to Firebase Storage

This script fetches all records with ASSET fields from CloudKit, downloads the assets,
uploads them to Firebase Storage, and updates the Firestore documents with new URLs.
"""

import argparse
import json
import os
import base64
import hashlib
import urllib.request
import urllib.parse
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.backends import default_backend
from google.cloud import firestore
from google.cloud import storage
from google.oauth2 import service_account

# CloudKit configuration
CLOUDKIT_CONTAINER = "iCloud.krishmittal.HouseRizz-iOS"
CLOUDKIT_ENVIRONMENT = "production"
CLOUDKIT_API_VERSION = "1"

# Record types with assets and their asset fields
ASSET_RECORDS = {
    "Products": {
        "collection": "products",
        "asset_fields": ["imageURL1", "imageURL2", "imageURL3", "modelURL"]
    },
    "Orders": {
        "collection": "orders",
        "asset_fields": ["imageURL"]
    },
    "ProductCategory": {
        "collection": "productCategories",
        "asset_fields": ["imageURL"]
    },
    "City": {
        "collection": "cities",
        "asset_fields": ["imageURL"]
    },
    "AddBanner": {
        "collection": "addBanners",
        "asset_fields": ["imageURL"]
    },
    "AIVibe": {
        "collection": "aiVibes",
        "asset_fields": ["imageURL"]
    },
}


class CloudKitClient:
    """CloudKit Web Services API client"""
    
    def __init__(self, container: str, key_id: str, key_file: str, environment: str = "production"):
        self.container = container
        self.key_id = key_id
        self.environment = environment
        self.base_url = f"https://api.apple-cloudkit.com/database/{CLOUDKIT_API_VERSION}/{container}/{environment}/public"
        
        with open(key_file, 'rb') as f:
            self.private_key = serialization.load_pem_private_key(
                f.read(),
                password=None,
                backend=default_backend()
            )
    
    def _sign_request(self, date: str, body: str, path: str) -> str:
        body_hash = base64.b64encode(hashlib.sha256(body.encode('utf-8')).digest()).decode('utf-8')
        message = f"{date}:{body_hash}:{path}"
        signature = self.private_key.sign(
            message.encode('utf-8'),
            ec.ECDSA(hashes.SHA256())
        )
        return base64.b64encode(signature).decode('utf-8')
    
    def _make_request(self, endpoint: str, data: dict) -> dict:
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
            print(f"   ❌ CloudKit API Error: {e.code} - {error_body}")
            raise
    
    def fetch_all_records(self, record_type: str) -> List[dict]:
        all_records = []
        continuation_marker = None
        
        while True:
            data = {
                "query": {"recordType": record_type},
                "resultsLimit": 200
            }
            if continuation_marker:
                data["continuationMarker"] = continuation_marker
            
            result = self._make_request("/records/query", data)
            records = result.get("records", [])
            all_records.extend(records)
            
            continuation_marker = result.get("continuationMarker")
            if not continuation_marker:
                break
        
        return all_records


def download_asset(url: str) -> bytes:
    """Download asset from URL"""
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=30) as response:
        return response.read()


def detect_extension(data: bytes) -> str:
    """Detect file extension from magic bytes"""
    if len(data) >= 4:
        if data[:3] == b'\xff\xd8\xff':
            return "jpg"
        elif data[:4] == b'\x89PNG':
            return "png"
        elif data[:4] == b'PK\x03\x04':
            return "usdz"
        elif data[:4] == b'GIF8':
            return "gif"
    return "bin"


def main():
    parser = argparse.ArgumentParser(description="Migrate CloudKit assets to Firebase Storage")
    parser.add_argument("--key-id", required=True, help="CloudKit Key ID")
    parser.add_argument("--key-file", required=True, help="CloudKit private key (.pem)")
    parser.add_argument("--service-account", required=True, help="Firebase service account JSON")
    parser.add_argument("--bucket", default="houserizz-481012.appspot.com", help="Storage bucket")
    parser.add_argument("--dry-run", action="store_true", help="Preview only")
    args = parser.parse_args()
    
    print("🖼️ CloudKit Assets to Firebase Storage Migration")
    print("=" * 50)
    print(f"📦 Container: {CLOUDKIT_CONTAINER}")
    print(f"🔄 Dry Run: {args.dry_run}\n")
    
    # Initialize clients
    print("🔧 Initializing...")
    ck = CloudKitClient(CLOUDKIT_CONTAINER, args.key_id, args.key_file, CLOUDKIT_ENVIRONMENT)
    
    credentials = service_account.Credentials.from_service_account_file(args.service_account)
    db = firestore.Client(credentials=credentials, project=credentials.project_id)
    storage_client = storage.Client(credentials=credentials, project=credentials.project_id)
    bucket = storage_client.bucket(args.bucket)
    
    print("✅ Initialized\n")
    
    total_assets = 0
    uploaded_assets = 0
    
    for record_type, config in ASSET_RECORDS.items():
        collection = config["collection"]
        asset_fields = config["asset_fields"]
        
        print(f"📋 Processing {record_type} → {collection}...")
        
        try:
            records = ck.fetch_all_records(record_type)
            print(f"   Found {len(records)} records")
            
            for record in records:
                record_name = record.get("recordName", "")
                fields = record.get("fields", {})
                updates = {}
                
                for field_name in asset_fields:
                    if field_name not in fields:
                        continue
                    
                    field_data = fields[field_name]
                    field_type = field_data.get("type", "")
                    
                    # CloudKit returns assets as ASSETID type
                    if field_type not in ("ASSET", "ASSETID"):
                        continue
                    
                    asset_value = field_data.get("value", {})
                    download_url = asset_value.get("downloadURL", "")
                    
                    if not download_url:
                        print(f"      ⚠️ No downloadURL for {record_name}/{field_name}")
                        continue
                    
                    total_assets += 1
                    
                    if args.dry_run:
                        print(f"      [DRY] Would download: {field_name} from {download_url[:60]}...")
                        continue
                    
                    try:
                        # Download from CloudKit
                        data = download_asset(download_url)
                        ext = detect_extension(data)
                        
                        # Upload to Firebase Storage
                        blob_path = f"migrated/{record_name}/{field_name}.{ext}"
                        blob = bucket.blob(blob_path)
                        
                        content_type = {
                            "jpg": "image/jpeg",
                            "png": "image/png",
                            "usdz": "model/vnd.usdz+zip",
                            "gif": "image/gif"
                        }.get(ext, "application/octet-stream")
                        
                        blob.upload_from_string(data, content_type=content_type)
                        blob.make_public()
                        
                        # Get public URL
                        public_url = blob.public_url
                        updates[field_name] = public_url
                        uploaded_assets += 1
                        
                        print(f"      ✅ {field_name}: {len(data)} bytes → {blob_path}")
                        
                    except Exception as e:
                        print(f"      ❌ Failed {field_name}: {e}")
                
                # Update Firestore document
                if updates and not args.dry_run:
                    db.collection(collection).document(record_name).update(updates)
                    print(f"      📝 Updated doc: {len(updates)} fields")
            
            print(f"   ✅ Done\n")
            
        except Exception as e:
            print(f"   ❌ Error: {e}\n")
    
    print("=" * 50)
    print(f"📊 Summary: {uploaded_assets}/{total_assets} assets uploaded")
    print("🎉 Asset migration complete!")


if __name__ == "__main__":
    main()
