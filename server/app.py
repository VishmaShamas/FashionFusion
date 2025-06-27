import io, torch, open_clip, numpy as np
from PIL import Image
from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr
import dns.resolver
import smtplib
import base64
import os
from rembg import remove
import json
from fastapi.middleware.cors import CORSMiddleware
from fastapi import Query
import open_clip


from fastapi.staticfiles import StaticFiles

# wardrobe

app = FastAPI(title="Wardrobe Upload API")
app.mount("/assets", StaticFiles(directory="assets"), name="assets")


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

SIM_THRESHOLD = 0.25

# Load CLIP model
# Load CLIP model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, _, preprocess = open_clip.create_model_and_transforms(
    model_name="ViT-B-32",
    pretrained="openai",
    device=device
)
tokenizer = open_clip.get_tokenizer("ViT-B-32")

@torch.inference_mode()
def encode_imgs(img):
    return model.encode_image(preprocess(img).unsqueeze(0).to(device))

@torch.inference_mode()
def encode_text(txts):
    toks = tokenizer(txts).to(device)
    return model.encode_text(toks)

cat_prompts = [f"a photo of a man wearing {c}" for c in CATS]
gender_prompts = ["men's clothing", "women's clothing"]

cat_emb = encode_text(cat_prompts)
gender_emb = encode_text(gender_prompts)
cat_emb = cat_emb / cat_emb.norm(dim=-1, keepdim=True)
gender_emb = gender_emb / gender_emb.norm(dim=-1, keepdim=True)


def classify(img: Image.Image):
    im = encode_imgs(img)
    im = im / im.norm(dim=-1, keepdim=True)
    g_sim = (im @ gender_emb.T).cpu().squeeze(0).tolist()
    male_score, female_score = g_sim
    sims = (im @ cat_emb.T).cpu().squeeze(0)
    topk = sims.topk(3)
    best_idx, best_val = topk.indices[0].item(), topk.values[0].item()
    best_cat = CATS[best_idx]
    valid_male = (male_score > female_score) or (best_cat in MALE_ONLY)
    return best_cat, float(best_val), valid_male, im.squeeze(0).cpu()


@app.post("/upload-wardrobe")
async def upload_wardrobe(
    user_id: str = Form(...),
    image: UploadFile = File(...)
):
    try:
        img_bytes = await image.read()
        img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    except Exception:
        raise HTTPException(status_code=400, detail="Cannot read image")

    category, conf, is_male, feature_tensor = classify(img)

    if conf < SIM_THRESHOLD:
        return JSONResponse({"valid": False, "reason": "Image unlikely to be clothing"})
    if not is_male:
        return JSONResponse({"valid": False, "reason": "Detected as non-male clothing"})

    # Remove background
    try:
        no_bg_img = remove(img_bytes)
        save_folder = f"wardrobe_images/{user_id}"
        os.makedirs(save_folder, exist_ok=True)
        image_filename = f"{category}_{len(os.listdir(save_folder))+1}.png"
        image_path = os.path.join(save_folder, image_filename)
        with open(image_path, "wb") as f:
            f.write(no_bg_img)
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to remove background")

    # Save features
    emb_path = f"{user_id}_features.pkl"
    file_path = f"{user_id}_filenames.pkl"

    if os.path.exists(emb_path):
        features = pickle.load(open(emb_path, "rb"))
        files = pickle.load(open(file_path, "rb"))
        features = torch.cat([features, feature_tensor.unsqueeze(0)], dim=0)
        files.append(image_path)
    else:
        features = feature_tensor.unsqueeze(0)
        files = [image_path]

    pickle.dump(features, open(emb_path, "wb"))
    pickle.dump(files, open(file_path, "wb"))

    return {
        "valid": True,
        "category": category,
        "confidence": round(conf, 3),
        "saved_image": image_path
    }

# image rrecommendation
TOP_K =  5
SIM_THRESHOLD = 0.25
EMBEDDING_FILE = "clip_embeddings.pkl"
FILENAME_FILE = "clip_filenames.pkl"
PRODUCTS_JSON = "cleaned_products.json"

# Load product metadata
with open(PRODUCTS_JSON, "r", encoding="utf-8") as f:
    product_data = json.load(f)

# Load model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, _, preprocess = open_clip.create_model_and_transforms('ViT-B-32', pretrained='laion2b_s34b_b79k')
model = model.to(device)
model.eval()

# Load catalog embeddings
catalog_features = pickle.load(open(EMBEDDING_FILE, "rb"))
catalog_paths = pickle.load(open(FILENAME_FILE, "rb"))

def extract_feature(image_data):
    image = Image.open(io.BytesIO(image_data)).convert("RGB")
    grayscale = image.convert("L")
    pixels = np.array(grayscale).astype(np.float32)
    mean_val = pixels.mean()
    std_dev = pixels.std()
    if (mean_val < 10 and std_dev < 40) or (mean_val > 245 and std_dev < 5):
        raise ValueError("Image is too dark, bright or uniform. Try another one.")

    image = preprocess(image).unsqueeze(0).to(device)
    with torch.no_grad():
        feature = model.encode_image(image)
        feature = feature / feature.norm(dim=-1, keepdim=True)
    return feature.squeeze(0)

@app.post("/search-by-image")
async def search_by_image(
    file: UploadFile = File(...),
    user_id: str = Query(None),
    from_wardrobe: bool = Query(False)
):
    try:
        image_data = await file.read()
        query_feat = extract_feature(image_data)

        # Decide whether to use wardrobe or catalog
        if from_wardrobe:
            if not user_id:
                raise HTTPException(status_code=400, detail="user_id required for wardrobe search.")
            feat_path = f"{user_id}_features.pkl"
            name_path = f"{user_id}_filenames.pkl"
            if not os.path.exists(feat_path) or not os.path.exists(name_path):
                raise HTTPException(status_code=404, detail="No wardrobe data found for this user.")
            image_features = pickle.load(open(feat_path, "rb")).to(device)
            image_paths = pickle.load(open(name_path, "rb"))
        else:
            image_features = catalog_features.to(device)
            image_paths = catalog_paths

        sims = image_features @ query_feat.unsqueeze(1)
        sims = sims.squeeze(1)

        if sims.max().item() < SIM_THRESHOLD:
            raise ValueError("Image doesn't match well. Try a better one.")

        top_indices = sims.topk(TOP_K).indices.cpu().numpy()

        results = []
        for idx in top_indices:
            path = image_paths[idx]
            score = sims[idx].item()

            try:
                filename = os.path.basename(path)
                product_index = int(filename.split("_")[-1].split(".")[0]) - 1
                product = product_data[product_index] if not from_wardrobe else None
            except:
                product = None

            if product:
                results.append({
                    "title": product.get("title", "Unknown"),
                    "brand": product.get("brand", "N/A"),
                    "price": product.get("price", "N/A"),
                    "shop_link": product.get("url", "N/A"),
                    "image": product.get("image", "N/A"),
                    "score": round(score, 4)
                })
            else:
                results.append({
                    "filename": path,
                    "score": round(score, 4),
                    "metadata": None
                })

        return JSONResponse(content={"results": results, "source": "wardrobe" if from_wardrobe else "catalog"})

    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Something went wrong during image processing.")



# text recommendation
# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Load Data and Model
# -----------------------------
TOP_K = 5
SIM_THRESHOLD = 0.25
EMBEDDING_FILE = "clip_embeddings.pkl"
FILENAME_FILE = "clip_filenames.pkl"
PRODUCTS_JSON = "cleaned_products.json"

# Product catalog embeddings
image_features = pickle.load(open(EMBEDDING_FILE, "rb"))
image_paths = pickle.load(open(FILENAME_FILE, "rb"))

# Load product metadata
with open(PRODUCTS_JSON, "r", encoding="utf-8") as f:
    product_data = json.load(f)

# Load model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, _, preprocess = open_clip.create_model_and_transforms('ViT-B-32', pretrained='laion2b_s34b_b79k')
tokenizer = open_clip.get_tokenizer('ViT-B-32')
model = model.to(device)
model.eval()

# -----------------------------
# Text-to-Image Search Helper
# -----------------------------
def get_top_matches(query: str, user_id=None, from_wardrobe=False, top_k=TOP_K):
    with torch.no_grad():
        # Encode text
        text_tokens = tokenizer([query]).to(device)
        text_features = model.encode_text(text_tokens)
        text_features /= text_features.norm(dim=-1, keepdim=True)

        # Decide source: wardrobe or catalog
        if from_wardrobe:
            emb_path = f"{user_id}_features.pkl"
            file_path = f"{user_id}_filenames.pkl"
            if not os.path.exists(emb_path) or not os.path.exists(file_path):
                raise HTTPException(status_code=404, detail="No wardrobe data found for this user.")
            image_features_gpu = pickle.load(open(emb_path, "rb")).to(device)
            image_paths_used = pickle.load(open(file_path, "rb"))
        else:
            image_features_gpu = image_features.to(device)
            image_paths_used = image_paths

        # Compute similarity
        sims = image_features_gpu @ text_features.T
        sims = sims.squeeze(1)

        if sims.max().item() < SIM_THRESHOLD:
            return []

        top_indices = sims.topk(top_k).indices.cpu().numpy()

        results = []
        for idx in top_indices:
            path = image_paths_used[idx]
            score = sims[idx].item()

            try:
                filename = os.path.basename(path)
                product_index = int(filename.split("_")[-1].split(".")[0]) - 1
                product = product_data[product_index]
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

        return results

# -----------------------------
# API Endpoint
# -----------------------------
@app.get("/search")
def search_products(
    query: str = Query(..., min_length=2),
    user_id: str = Query(None),
    from_wardrobe: bool = Query(False)
):
    results = get_top_matches(query, user_id=user_id, from_wardrobe=from_wardrobe)
    if not results:
        source = "wardrobe" if from_wardrobe else "catalog"
        return {"message": f"No similar outfits found in your {source}.", "results": []}
    
    return {"results": results, "source": "wardrobe" if from_wardrobe else "catalog"}





























if __name__ == "__main__":
    import uvicorn
    import socket

    # Get your machine's IPv4 address
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)

    uvicorn.run(
        "app:app",  # replace 'app' with your filename if different
        host="192.168.1.7",  # bind to your local IPv4
        port=8000,
        reload=True
    )


