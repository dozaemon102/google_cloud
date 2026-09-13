import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.cloud import firestore

app = FastAPI()

allowed_origins = [
    origin.strip()
    for origin in os.environ.get(
        "ALLOWED_ORIGINS",
        "http://localhost:5173,http://127.0.0.1:5173",
    ).split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

db = firestore.Client()

@app.get("/cities/{city_id}/risk")
def get_risk_status(city_id: str):
    doc = db.collection("risk_statuses").document(city_id).get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Risk status not found")

    return {
        "city_id": doc.get("city_id"),
        "forecast_at": doc.get("forecast_at"),
        "wbgt_estimate": doc.get("wbgt_estimate"),
        "risk_level": doc.get("risk_level"),
    }

@app.get("/cities")
def get_cities():
    return [
        "sapporo",
        "sendai",
        "tokyo",
        "nagoya",
        "osaka",
        "kyoto",
        "hiroshima",
        "fukuoka",
        "nagasaki",
        "naha",
    ]