#!/usr/bin/env python3
"""Debug script to inspect CloudKit record structure"""

import json
import base64
import hashlib
import urllib.request
import urllib.parse
from datetime import datetime, timezone
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.backends import default_backend

CLOUDKIT_CONTAINER = "iCloud.krishmittal.HouseRizz-iOS"
KEY_ID = "6b6d55c6c64a2bbb99b3865d31362563c3e0493f31d1f1eb74f7775bd136178b"
KEY_FILE = "/Users/krishmittal/Developer/projects/houserizz/HouseRizz-iOS/MigrationTool/eckey.pem"

with open(KEY_FILE, 'rb') as f:
    private_key = serialization.load_pem_private_key(f.read(), password=None, backend=default_backend())

def sign_request(date, body, path):
    body_hash = base64.b64encode(hashlib.sha256(body.encode('utf-8')).digest()).decode('utf-8')
    message = f"{date}:{body_hash}:{path}"
    signature = private_key.sign(message.encode('utf-8'), ec.ECDSA(hashes.SHA256()))
    return base64.b64encode(signature).decode('utf-8')

# Query a record with assets
base_url = f"https://api.apple-cloudkit.com/database/1/{CLOUDKIT_CONTAINER}/production/public"
url = f"{base_url}/records/query"
path = urllib.parse.urlparse(url).path

data = {
    "query": {"recordType": "Products"},
    "resultsLimit": 1,
    "desiredKeys": ["imageURL1", "imageURL2", "imageURL3", "modelURL", "name"]
}
body = json.dumps(data)
date = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
signature = sign_request(date, body, path)

headers = {
    'Content-Type': 'application/json',
    'X-Apple-CloudKit-Request-KeyID': KEY_ID,
    'X-Apple-CloudKit-Request-ISO8601Date': date,
    'X-Apple-CloudKit-Request-SignatureV1': signature,
}

req = urllib.request.Request(url, data=body.encode('utf-8'), headers=headers, method='POST')

with urllib.request.urlopen(req) as response:
    result = json.loads(response.read().decode('utf-8'))
    print(json.dumps(result, indent=2))
