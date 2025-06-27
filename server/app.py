from fastapi import FastAPI, Query, File, Form, UploadFile, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import torch
import pickle
import open_clip
import os
import json
import numpy as np
import io
from rembg import remove

app = FastAPI(title="Unified FashionFusion API")

# -----------------------------
# CORS Setup
# -----------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Configuration
# -----------------------------
TOP_K = 5
SIM_THRESHOLD = 0.25
EMBEDDING_FILE = "clip_embeddings.pkl"
FILENAME_FILE = "clip_filenames.pkl"
PRODUCTS_JSON = "cleaned_products.json"
CATS = [
    "shirt", "polo", "t-shirt", "denim jacket", "jeans", "pants", "cargo pants",
    "sweater", "jacket", "shawl", "kurta", "kurta pajama", "shalwar qameez",
    "waistcoat", "Format Suit", "sportswear", "tank top",
    "vest", "achkan", "prince coat", "shorts", "hoodie"
]
MALE_ONLY = {
    "kurta", "kurta pajama", "shalwar qameez", "waistcoat", "Format Suit",
    "Prince Coat", "achkan", "prince coat"
}

# -----------------------------
# Load Resources
# -----------------------------
with open(PRODUCTS_JSON, "r", encoding="utf-8") as f:
    product_data = json.load(f)

catalog_features = pickle.load(open(EMBEDDING_FILE, "rb"))
catalog_paths = pickle.load(open(FILENAME_FILE, "rb"))

# CLIP Model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, _, preprocess = open_clip.create_model_and_transforms('ViT-B-32', pretrained='laion2b_s34b_b79k')
model = model.to(device)
model.eval()
tokenizer = open_clip.get_tokenizer("ViT-B-32")

cat_prompts = [f"a photo of a man wearing {c}" for c in CATS]
gender_prompts = ["men's clothing", "women's clothing"]
cat_emb = model.encode_text(tokenizer(cat_prompts).to(device))
gender_emb = model.encode_text(tokenizer(gender_prompts).to(device))
cat_emb = cat_emb / cat_emb.norm(dim=-1, keepdim=True)
gender_emb = gender_emb / gender_emb.norm(dim=-1, keepdim=True)

# -----------------------------
# Utility Functions
# -----------------------------
def validate_image(img_bytes):
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    gray = img.convert("L")
    pixels = np.array(gray).astype(np.float32)
    if (pixels.mean() < 10 and pixels.std() < 40) or (pixels.mean() > 245 and pixels.std() < 5):
        raise ValueError("Image is too dark, bright or uniform.")
    return img

def extract_feature(img):
    with torch.no_grad():
        tensor = preprocess(img).unsqueeze(0).to(device)
        feat = model.encode_image(tensor)
        return (feat / feat.norm(dim=-1, keepdim=True)).squeeze(0)

def classify_image(img):
    img_tensor = preprocess(img).unsqueeze(0).to(device)
    with torch.no_grad():
        im_feat = model.encode_image(img_tensor)
        im_feat = im_feat / im_feat.norm(dim=-1, keepdim=True)
        g_sim = (im_feat @ gender_emb.T).squeeze(0).tolist()
        male_score, female_score = g_sim
        sims = (im_feat @ cat_emb.T).squeeze(0)
        best_idx = sims.topk(1).indices[0].item()
        best_val = sims[best_idx].item()
        category = CATS[best_idx]
        is_male = (male_score > female_score) or (category in MALE_ONLY)
        return category, best_val, is_male, im_feat.squeeze(0).cpu()

# -----------------------------
# API 1: Upload to Wardrobe
# -----------------------------
@app.post("/upload-wardrobe")
async def upload_wardrobe(user_id: str = Form(...), image: UploadFile = File(...)):
    try:
        img_bytes = await image.read()
        img = validate_image(img_bytes)
        category, conf, is_male, feature_tensor = classify_image(img)

        if conf < SIM_THRESHOLD:
            return {"valid": False, "reason": "Image unlikely to be clothing"}
        if not is_male:
            return {"valid": False, "reason": "Detected as non-male clothing"}

        no_bg_img = remove(img_bytes)
        save_folder = f"wardrobe_images/{user_id}"
        os.makedirs(save_folder, exist_ok=True)
        filename = f"{category}_{len(os.listdir(save_folder)) + 1}.png"
        path = os.path.join(save_folder, filename)
        with open(path, "wb") as f:
            f.write(no_bg_img)

        emb_path = f"{user_id}_features.pkl"
        file_path = f"{user_id}_filenames.pkl"
        if os.path.exists(emb_path):
            feats = pickle.load(open(emb_path, "rb"))
            names = pickle.load(open(file_path, "rb"))
            feats = torch.cat([feats, feature_tensor.unsqueeze(0)], dim=0)
            names.append(path)
        else:
            feats = feature_tensor.unsqueeze(0)
            names = [path]

        pickle.dump(feats, open(emb_path, "wb"))
        pickle.dump(names, open(file_path, "wb"))

        url_path = f"/wardrobe_images/{user_id}/{filename}"
        return {
            "valid": True,
            "category": category,
            "confidence": round(conf, 3),
            "saved_image": url_path  # ✅ This is served via FastAPI static route
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    

# -----------------------------
# API 2: Search by Text
# -----------------------------
@app.get("/search")
def search_by_text(query: str = Query(..., min_length=2), user_id: str = Query(None), from_wardrobe: bool = Query(False)):
    with torch.no_grad():
        text_feat = model.encode_text(tokenizer([query]).to(device))
        text_feat = text_feat / text_feat.norm(dim=-1, keepdim=True)

        if from_wardrobe:
            emb_path = f"{user_id}_features.pkl"
            file_path = f"{user_id}_filenames.pkl"
            if not os.path.exists(emb_path) or not os.path.exists(file_path):
                raise HTTPException(status_code=404, detail="No wardrobe data found.")
            features = pickle.load(open(emb_path, "rb")).to(device)
            paths = pickle.load(open(file_path, "rb"))
        else:
            features = catalog_features.to(device)
            paths = catalog_paths

        sims = features @ text_feat.T
        sims = sims.squeeze(1)
        if sims.max().item() < SIM_THRESHOLD:
            return {"message": "No similar outfits found.", "results": []}

        indices = sims.topk(TOP_K).indices.cpu().numpy()
        results = []
        for idx in indices:
            path = paths[idx]
            score = sims[idx].item()
            try:
                product_index = int(os.path.basename(path).split("_")[-1].split(".")[0]) - 1
                product = product_data[product_index] if not from_wardrobe else None
            except:
                product = None

            results.append({
                "title": product.get("title", "Unknown") if product else "N/A",
                "brand": product.get("brand", "N/A") if product else "N/A",
                "price": product.get("price", "N/A") if product else "N/A",
                "shop_link": product.get("url", "N/A") if product else "N/A",
                "image_url": product.get("image", path) if product else path,
                "score": round(score, 4)
            })

        return {"results": results, "source": "wardrobe" if from_wardrobe else "catalog"}

# -----------------------------
# API 3: Search by Image
# -----------------------------
@app.post("/search-by-image")
async def search_by_image(file: UploadFile = File(...), user_id: str = Query(None), from_wardrobe: bool = Query(False)):
    try:
        img_bytes = await file.read()
        img = validate_image(img_bytes)
        query_feat = extract_feature(img)

        if from_wardrobe:
            if not user_id:
                raise HTTPException(status_code=400, detail="user_id required for wardrobe search.")
            feat_path = f"{user_id}_features.pkl"
            name_path = f"{user_id}_filenames.pkl"
            if not os.path.exists(feat_path) or not os.path.exists(name_path):
                raise HTTPException(status_code=404, detail="No wardrobe data found.")
            features = pickle.load(open(feat_path, "rb")).to(device)
            paths = pickle.load(open(name_path, "rb"))
        else:
            features = catalog_features.to(device)
            paths = catalog_paths

        sims = features @ query_feat.unsqueeze(1)
        sims = sims.squeeze(1)
        if sims.max().item() < SIM_THRESHOLD:
            raise ValueError("Image doesn't match well. Try a better one.")

        indices = sims.topk(TOP_K).indices.cpu().numpy()
        results = []
        for idx in indices:
            path = paths[idx]
            score = sims[idx].item()
            try:
                product_index = int(os.path.basename(path).split("_")[-1].split(".")[0]) - 1
                product = product_data[product_index] if not from_wardrobe else None
            except:
                product = None

            results.append({
                "title": product.get("title", "Unknown") if product else "N/A",
                "brand": product.get("brand", "N/A") if product else "N/A",
                "price": product.get("price", "N/A") if product else "N/A",
                "shop_link": product.get("url", "N/A") if product else "N/A",
                "image_url": product.get("image", path) if product else path,
                "score": round(score, 4)
            })

        return {"results": results, "source": "wardrobe" if from_wardrobe else "catalog"}

    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception:
        raise HTTPException(status_code=500, detail="Something went wrong during image processing.")



app.mount("/wardrobe_images", StaticFiles(directory="wardrobe_images"), name="wardrobe")

if __name__ == "__main__":
    import uvicorn
    import socket

    # Get your local IPv4 address dynamically
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)

    print(f"Running server on IP: {ip_address}")

    uvicorn.run(
        "app:app",
        host=ip_address,
        port=8000,
        reload=True
    )
