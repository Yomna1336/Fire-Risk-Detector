import os
import io
import csv
import math

import requests

from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict
from functools import lru_cache
from dotenv import load_dotenv

from datetime import datetime
from math import radians, sin, cos, sqrt, atan2


# ==========================================
# 1. إعداد NASA FIRMS
# ==========================================

ENV_PATH = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(ENV_PATH)

FIRMS_MAP_KEY = os.getenv("FIRMS_MAP_KEY")

BASE_URL = "https://firms.modaps.eosdis.nasa.gov/api"

# مصادر بيانات MODIS و VIIRS
FIRMS_SOURCES = [
    "MODIS_SP",
    "MODIS_NRT",
    "VIIRS_SNPP_SP",
    "VIIRS_SNPP_NRT",
    "VIIRS_NOAA20_SP",
    "VIIRS_NOAA20_NRT",
    "VIIRS_NOAA21_SP",
    "VIIRS_NOAA21_NRT",
]


# ==========================================
# 2. تحويل تاريخ ووقت الرصد
# ==========================================

def get_fire_datetime(point):

    date = point["acq_date"]
    time = str(point["acq_time"]).zfill(4)

    return datetime.strptime(
        f"{date} {time}",
        "%Y-%m-%d %H%M"
    )


# ==========================================
# 3. إنشاء النطاق الجغرافي
# ==========================================

def create_bounding_box(latitude, longitude, radius_km=5):

    lat_change = radius_km / 111.0

    cos_lat = math.cos(math.radians(latitude))

    if abs(cos_lat) < 0.000001:
        raise ValueError("Invalid latitude for bounding box")

    lon_change = radius_km / (111.0 * abs(cos_lat))

    south = max(-90, latitude - lat_change)
    north = min(90, latitude + lat_change)

    west = max(-180, longitude - lon_change)
    east = min(180, longitude + lon_change)

    return f"{west},{south},{east},{north}"


# ==========================================
# 4. حساب المسافة بين نقطتين
# ==========================================

def calculate_distance(lat1, lon1, lat2, lon2):

    R = 6371.0

    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)

    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2) ** 2
    )

    c = 2 * math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a)
    )

    return R * c


# ==========================================
# 5. جلب البيانات التاريخية من NASA
# ==========================================

@lru_cache(maxsize=1024)
def fetch_historical_data(source, bbox, start_date, days):

    if not FIRMS_MAP_KEY:
        raise ValueError("NASA FIRMS MAP_KEY is missing")

    url = (
        f"{BASE_URL}/area/csv/"
        f"{FIRMS_MAP_KEY}/{source}/{bbox}/{days}/{start_date}"
    )

    response = requests.get(url, timeout=60)
    response.raise_for_status()

    print("FIRMS STATUS:", response.status_code)
    print("FIRMS RESPONSE:")
    print(response.text[:1000])

    reader = csv.DictReader(
        io.StringIO(response.content.decode("utf-8-sig"))
    )
    print("CSV FIELDS:", reader.fieldnames)

    required_fields = {
        "latitude",
        "longitude",
        "acq_date",
        "acq_time",
        "frp"
    }

    if not reader.fieldnames or not required_fields.issubset(
        set(reader.fieldnames)
    ):
        raise RuntimeError(
            f"Unexpected NASA FIRMS response for {source}"
        )

    points = []

    for row in reader:

        try:
            print ("reading row" , row["latitude"] , row["longitude"])

            points.append({
                "latitude": float(row["latitude"]),
                "longitude": float(row["longitude"]),
                "frp": float(row["frp"]),
                "confidence": row.get("confidence", "unknown"),
                "acq_date": row["acq_date"],
                "acq_time": str(row["acq_time"]).zfill(4),
                "source": source
            })

        except (KeyError, ValueError, TypeError):
            continue

    print ("toltal appended" , len (points))
    return tuple(points)


# ==========================================
# 6. معرفة الفترات المتاحة في NASA
# ==========================================
@lru_cache(maxsize=1)
def fetch_data_availability():

    url = (
        f"https://firms.modaps.eosdis.nasa.gov/"
        f"api/data_availability/csv/{FIRMS_MAP_KEY}/all"
    )

    response = requests.get(url, timeout=30)
    response.raise_for_status()

    reader = csv.DictReader(
        io.StringIO(response.text)
    )

    availability = {}

    for row in reader:
        availability[row["data_id"]] = {
            "min_date": row["min_date"],
            "max_date": row["max_date"]
        }

    return availability


# ==========================================
# 7. جلب البيانات خلال فترة زمنية
# ==========================================

def fetch_available_period(
    source,
    bbox,
    start_date,
    end_date,
    availability
):

    if source not in availability:
        return []

    available_start = datetime.strptime(
        availability[source]["min_date"],
        "%Y-%m-%d"
    ).date()

    available_end = datetime.strptime(
        availability[source]["max_date"],
        "%Y-%m-%d"
    ).date()

    current_date = max(start_date, available_start)
    final_date = min(end_date, available_end)

    if current_date > final_date:
        return []

    all_points = []

    while current_date <= final_date:

        remaining_days = (
            final_date - current_date
        ).days + 1

        chunk_days = min(5, remaining_days)

        points = fetch_historical_data(
            source=source,
            bbox=bbox,
            start_date=current_date.isoformat(),
            days=chunk_days
        )

        all_points.extend(points)

        current_date += timedelta(days=chunk_days)

    return all_points


# ==========================================
# 8. تصفية الحرائق داخل نصف القطر
# ==========================================

def filter_nearby_fires(
    points,
    center_lat,
    center_lon,
    radius_km=5
):

    nearby_points = []

    for point in points:

        distance = calculate_distance(
            center_lat,
            center_lon,
            point["latitude"],
            point["longitude"]
        )

        if distance <= radius_km:

            point["distance_km"] = round(distance, 3)

            nearby_points.append(point)

    return nearby_points


# ==========================================
# 9. تجميع الحرائق الفريدة
# ==========================================

def group_unique_fires(points):

    points = sorted(
        points,
        key=get_fire_datetime
    )

    groups = []

    for point in points:

        point_time = get_fire_datetime(point)

        matching_group = None

        for group in groups:

            first_point = group[0]
            first_time = get_fire_datetime(first_point)

            time_difference = point_time - first_time

            if time_difference > timedelta(hours=12):
                continue

            distance = calculate_distance(
                first_point["latitude"],
                first_point["longitude"],
                point["latitude"],
                point["longitude"]
            )

            if distance <= 0.5:
                matching_group = group
                break

        if matching_group is not None:
            matching_group.append(point)
        else:
            groups.append([point])

    # Create unique fire summaries
    unique_fires = []

    for fire_number, group in enumerate(groups, start=1):

        for point in group:
            point["unique_fire_id"] = fire_number

        unique_fires.append({

            "unique_fire_id": fire_number,

            "latitude": sum(
                p["latitude"] for p in group
            ) / len(group),

            "longitude": sum(
                p["longitude"] for p in group
            ) / len(group),

            "first_seen": get_fire_datetime(group[0]).isoformat(),

            "last_seen": get_fire_datetime(group[-1]).isoformat(),

            "detections_count": len(group),

            "max_frp": max(
                p["frp"] for p in group
            ),

            "detections": group
        })

    return points, len(unique_fires), unique_fires

# ==========================================
# 10. حساب الإحصائيات التاريخية
# ==========================================

def calculate_historical_statistics(points):

    total_detections = len(points)

    unique_fire_ids = {
        point["unique_fire_id"]
        for point in points
    }

    satellite_stats = {
        "MODIS": 0,
        "VIIRS": 0
    }

    for point in points:
        source = point["source"]

        if source.startswith("MODIS"):
            satellite_stats["MODIS"] += 1

        elif source.startswith("VIIRS"):
            satellite_stats["VIIRS"] += 1

    return {
        "total_detections": total_detections,
        "estimated_unique_fires": len(unique_fire_ids),
        "satellite_statistics": satellite_stats
    }


# ==========================================
# 11. الدالة الرئيسية للمعلومات التاريخية
# ==========================================

def get_historical_fires(
    center_lat,
    center_lon,
    radius_km=5,
    days_back=365
):
    print ("historical service dayer:" , days_back)
    if not FIRMS_MAP_KEY:
        raise ValueError("NASA FIRMS MAP_KEY is missing")

    if not -90 <= center_lat <= 90:
        raise ValueError("Invalid latitude")

    if not -180 <= center_lon <= 180:
        raise ValueError("Invalid longitude")

    if days_back < 1:
        raise ValueError("days_back must be at least 1")

    bbox = create_bounding_box(
        center_lat,
        center_lon,
        radius_km
    )

    end_date = datetime.utcnow().date()

    start_date = end_date - timedelta(
        days=days_back - 1
    )

    availability = fetch_data_availability()

    all_points = []

    for source in FIRMS_SOURCES:

        points = fetch_available_period(
            source=source,
            bbox=bbox,
            start_date=start_date,
            end_date=end_date,
            availability=availability
        )

        all_points.extend(points)

    nearby_points = filter_nearby_fires(
        points=all_points,
        center_lat=center_lat,
        center_lon=center_lon,
        radius_km=radius_km
    )

    # Group detections into unique fires
    nearby_points, unique_fire_count, unique_fires = (
        group_unique_fires(nearby_points)
    )

    # Calculate historical statistics
    statistics = calculate_historical_statistics(
        nearby_points
    )

    return {
        "center": {
            "latitude": center_lat,
            "longitude": center_lon
        },
        "radius_km": radius_km,
        "days_back": days_back,
        "statistics": statistics,
        "unique_fire_count": unique_fire_count,
        "unique_fires": unique_fires,
        "detections": nearby_points
    }
  
