import json
from google.cloud import firestore
import os
import time

# Set Firebase credentials
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "./service.json"
db = firestore.Client()

# Load JSON data
data_path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'data2.json')
print("Looking for JSON at:", os.path.abspath(data_path))

with open(data_path, 'r', encoding='utf-8') as f:
    product_list = json.load(f)

# Firestore collection
collection_name = 'products'

# Upload from 14000th to 17000th product (list index 13999 to 16999)
start_index = 12000
end_index = 13000  # not inclusive in Python

for i in range(start_index, end_index):
    if i >= len(product_list):
        print(f"Index {i} exceeds product list length. Stopping.")
        break

    product = product_list[i]
    original_id = product.get('id')

    if not original_id or not original_id.startswith('p'):
        print(f"[{i}] Skipping invalid or missing ID.")
        continue

    try:
        id_number = int(original_id[1:])
    except ValueError:
        print(f"[{i}] Skipping invalid ID format: {original_id}")
        continue

    firestore_id = f'product{id_number}'
    doc_ref = db.collection(collection_name).document(firestore_id)

    # Directly write the document (no read)
    doc_ref.set(product)
    print(f"[{i}] Uploaded '{firestore_id}'")

    # Optional: add a small delay to avoid hitting Firestore rate limits
    time.sleep(0.05)  # 50ms
