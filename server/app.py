import io, torch, open_clip, numpy as np
from PIL import Image
from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr
import dns.resolver
import smtplib
import base64
import os
import pickle
from rembg import remove

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
        save_folder = os.path.join("assets", user_id)
        os.makedirs(save_folder, exist_ok=True)
        image_filename = f"{category}_{len(os.listdir(save_folder))+1}.png"
        image_path = os.path.join(save_folder, image_filename)
        with open(image_path, "wb") as f:
            f.write(no_bg_img)
        public_image_url = f"/assets/{user_id}/{image_filename}"
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
        "saved_image": public_image_url
    }





































if __name__ == "__main__":
    import uvicorn
    import socket

    # Get your machine's IPv4 address
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)

    uvicorn.run(
        "app:app",  # replace 'app' with your filename if different
        host=ip_address,  # bind to your local IPv4
        port=8000,
        reload=True
    )


