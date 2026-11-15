from dotenv import load_dotenv
import os
load_dotenv()
FIRMS_MAP_KEY = os.getenv("FIRMS_MAP_KEY")
from datetime import datetime
import io
import math
import csv
from fastapi import FastAPI, HTTPException
import requests
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="FireWatch Harmonization API", version="1.0")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def fetch_firms_data(map_key: str, source: str, bbox: str, day_range: int =5):
    url = f"https://firms.modaps.eosdis.nasa.gov/api/area/csv/{map_key}/{source}/{bbox}/{day_range}"
    response = requests.get(url)
    
    if response.status_code != 200:
        return []
    
    csv_data = response.content.decode('utf-8')
    reader = csv.DictReader(io.StringIO(csv_data))
    
    points = []
    for row in reader:
        try:
            points.append({
                "lat": float(row['latitude']),
                "lon": float(row['longitude']),
                "frp": float(row['frp']),
                "confidence": row.get('confidence', 'nominal'),
                "acq_date": row['acq_date'],
                "acq_time": str(row['acq_time']).zfill(4)
            })
        except (KeyError, ValueError):
            continue
            
    return points

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

def harmonize_hotspots(viirs_points, modis_points, max_distance_km=1.0, max_time_diff_seconds=3600):
    harmonized_list = []
    matched_modis_indices = set()

    for v in viirs_points:
        is_matched = False
        try:
            v_time = datetime.strptime(f"{v['acq_date']} {v['acq_time']}", "%Y-%m-%d %H%M")
        except ValueError:
            continue
        
        for idx, m in enumerate(modis_points):
            if idx in matched_modis_indices:
                continue
                
            try:
                m_time = datetime.strptime(f"{m['acq_date']} {m['acq_time']}", "%Y-%m-%d %H%M")
            except ValueError:
                continue
            
            distance = calculate_distance(v['lat'], v['lon'], m['lat'], m['lon'])
            time_diff = abs((v_time - m_time).total_seconds())

            if distance <= max_distance_km and time_diff <= max_time_diff_seconds:
                is_matched = True
                matched_modis_indices.add(idx)

                calibrated_modis_frp = m['frp'] * 1.25 
                merged_frp = (v['frp'] + calibrated_modis_frp) / 2.0

                harmonized_list.append({
                    "latitude": v['lat'],
                    "longitude": v['lon'],
                    "source": "Harmonized (VIIRS + MODIS)",
                    "frp": round(merged_frp, 2),
                    "confidence": str(v['confidence']),
                    "acq_date": v['acq_date'],
                    "acq_time": v['acq_time']
                })
                break

        if not is_matched:
            harmonized_list.append({
                "latitude": v['lat'],
                "longitude": v['lon'],
                "source": "VIIRS Only",
                "frp": v['frp'],
                "confidence": str(v['confidence']),
                "acq_date": v['acq_date'],
                "acq_time": v['acq_time']
            })

    for idx, m in enumerate(modis_points):
        if idx not in matched_modis_indices:
            harmonized_list.append({
                "latitude": m['lat'],
                "longitude": m['lon'],
                "source": "MODIS Only",
                "frp": round(m['frp'] * 1.25, 2),
                "confidence": str(m['confidence']),
                "acq_date": m['acq_date'],
                "acq_time": m['acq_time']
            })

    return harmonized_list
@app.get("/api/harmonized-fires")
def get_harmonized_fires(bbox: str = "25.0,22.0,36.0,32.0",  days: int = 5):
    map_key = FIRMS_MAP_KEY
    if not map_key: raise HTTPException(status_code=500 , detail= "NASA FIRMS MAP KEY IS MISSING")
    
    viirs_data = fetch_firms_data(map_key, "VIIRS_SNPP_NRT", bbox, day_range=days)
    modis_data = fetch_firms_data(map_key, "MODIS_NRT", bbox, day_range=days)
    
    if not viirs_data and not modis_data:
        return {"status": "success", "count": 0, "data": []}
        
    result = harmonize_hotspots(viirs_data, modis_data)
    
    return {
        "status": "success",
        "count": len(result),
        "data": result
    }