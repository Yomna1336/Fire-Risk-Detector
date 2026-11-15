import os
import numpy as np
import joblib
import requests

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

from services.historical_service import get_historical_fires


# ==========================================
# 1. إعداد التطبيق
# ==========================================

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==========================================
# 2. تحميل نموذج التنبؤ
# ==========================================

model_file = "wildfire_model.pkl"

if os.path.exists(model_file):
    model = joblib.load(model_file)
else:
    model = None


# ==========================================
# 3. نموذج استقبال الموقع
# ==========================================

class LocationRequest(BaseModel):
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    city: Optional[str] = None


# ==========================================
# 4. Endpoint التنبؤ بمخاطر الحرائق
# ==========================================

@app.post("/predict")
async def predict_by_location(data: LocationRequest):

    if model is None:
        return {"error": "النموذج غير متوفر"}

    try:
        lat = data.latitude
        lon = data.longitude

        if data.city:
            geo_url = (
                "https://geocoding-api.open-meteo.com/v1/search"
                f"?name={data.city}&count=1"
            )

            geo_res = requests.get(
                geo_url,
                timeout=20
            ).json()

            if "results" in geo_res and len(geo_res["results"]) > 0:
                lat = geo_res["results"][0]["latitude"]
                lon = geo_res["results"][0]["longitude"]
            else:
                return {
                    "error": "لم يتم العثور على المدينة المطلوبة"
                }

        if lat is None or lon is None:
            return {
                "error": "يرجى توفير الإحداثيات أو اسم المدينة"
            }

        weather_url = (
            f"https://api.open-meteo.com/v1/forecast"
            f"?latitude={lat}&longitude={lon}"
            "&current=temperature_2m,relative_humidity_2m,wind_speed_10m"
        )

        weather_res = requests.get(
            weather_url,
            timeout=20
        ).json()

        temperature = weather_res["current"]["temperature_2m"]
        humidity = weather_res["current"]["relative_humidity_2m"]
        wind_speed = weather_res["current"]["wind_speed_10m"]

        ndvi = 0.35

    except Exception:
        temperature = 25.0
        humidity = 50.0
        wind_speed = 10.0
        ndvi = 0.35
        lat = lat or 0.0
        lon = lon or 0.0

    features = np.array([
        [lat, lon, temperature, humidity, wind_speed, ndvi]
    ])

    prediction = int(model.predict(features)[0])

    probabilities = model.predict_proba(features)[0]

    risk_probability = (
        float(probabilities[1])
        if len(probabilities) > 1
        else (
            float(probabilities[0])
            if prediction == 1
            else 0.0
        )
    )

    return {
        "latitude": lat,
        "longitude": lon,
        "real_temperature": temperature,
        "real_humidity": humidity,
        "real_wind_speed": wind_speed,
        "is_fire_prone": prediction,
        "risk_probability": risk_probability
    }


# ==========================================
# 5. Historical Information
# ==========================================

@app.get("/historical-information")
async def historical_information(
    latitude: float,
    longitude: float
):

    try:
        print("dayes bake service 365")
        result = get_historical_fires(
            center_lat=latitude,
            center_lon=longitude,
            radius_km=5,
            days_back=365
        )

        return result

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )

 