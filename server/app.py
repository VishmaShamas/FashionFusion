import io, torch, open_clip, numpy as np
from PIL import Image
from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr
import dns.resolver
import smtplib
import base64

app = FastAPI(title="Male-Clothing API")

CATS = [
    "shirt", "polo", "t-shirt", "denim jacket", "jeans", "pants", "cargo pants",
    "sweater", "jacket", "shawl", "kurta", "kurta pajama", "shalwar qameez",
    "waistcoat", "Formal Suit", "sportswear", "tank top",
    "vest", "achkan", "prince coat", "shorts", "hoodie"
]

MALE_ONLY = {
    "kurta", "kurta pajama", "shalwar qameez", "waistcoat", "Formal Suit",
    "Prince Coat", "achkan", "prince coat"
}

class EmailRequest(BaseModel):
    email: EmailStr

def has_mx_record(domain):
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        return len(mx_records) > 0
    except Exception:
        return False

def check_email_smtp(email):
    domain = email.split('@')[1]
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        mx_record = str(mx_records[0].exchange)
        # Try connecting to the SMTP server
        server = smtplib.SMTP(timeout=10)
        server.connect(mx_record)
        server.helo('example.com')
        server.mail('test@example.com')
        code, message = server.rcpt(email)
        server.quit()
        # 250 is success, 550 is mailbox unavailable
        return code == 250
    except Exception as e:
        return False

@app.post("/verify_email")
async def verify_email(request: EmailRequest):
    email = request.email
    domain = email.split('@')[1]

    if not has_mx_record(domain):
        return {"valid_syntax": True, "has_mx": False, "exists": False}

    exists = check_email_smtp(email)
    return {
        "valid_syntax": True,
        "has_mx": True,
        "exists": exists
    }
    
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

cat_prompts   = [f"a photo of a man wearing {c}" for c in CATS]
gender_prompts = ["men's clothing", "women's clothing"]

cat_emb   = encode_text(cat_prompts)      # shape (24, dim)
gender_emb = encode_text(gender_prompts)  # shape (2 , dim)
cat_emb = cat_emb / cat_emb.norm(dim=-1, keepdim=True)
gender_emb = gender_emb / gender_emb.norm(dim=-1, keepdim=True)

SIM_THRESHOLD = 0.25

def classify(img: Image.Image):
    im = encode_imgs(img)
    im = im / im.norm(dim=-1, keepdim=True)
    g_sim = (im @ gender_emb.T).cpu().squeeze(0).tolist()
    male_score, female_score = g_sim
    sims  = (im @ cat_emb.T).cpu().squeeze(0)
    topk  = sims.topk(3)
    best_idx, best_val = topk.indices[0].item(), topk.values[0].item()
    best_cat = CATS[best_idx]
    valid_male = (male_score > female_score) or (best_cat in MALE_ONLY)
    return best_cat, float(best_val), valid_male

@app.post("/predict")
async def predict(
    email: str = Form(..., max_length=254),
    image: UploadFile = File(...)
):
    try:
        img = Image.open(io.BytesIO(await image.read())).convert("RGB")
    except Exception:
        raise HTTPException(status_code=400, detail="Cannot read image")
    cat, conf, is_male = classify(img)
    if conf < SIM_THRESHOLD:
        return JSONResponse({"valid": False, "reason": "Image unlikely to be clothing"})
    if not is_male:
        return JSONResponse({"valid": False, "reason": "Detected as non-male clothing"})

    print ({
        "valid":   True,
        "email":   email,
        "category": cat,
        "image": f"data:image/jpeg;base64,{base64.b64encode(await image.read()).decode()}",
        "confidence": round(conf, 3)
    })
    return {
        "valid":   True,
        "email":   email,
        "category": cat,
        "image": f"data:image/jpeg;base64,{base64.b64encode(await image.read()).decode()}",
        "confidence": round(conf, 3)
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
