from services.historical_service import (
    FIRMS_MAP_KEY,
    fetch_historical_data
)

print("MAP KEY loaded:", bool(FIRMS_MAP_KEY))

points = fetch_historical_data(
    source="MODIS_NRT",
    bbox="29.0,28.0,32.0,31.0",
    start_date="2026-11-09",
    days=365
)

print("Returned type:", type(points))
print("Number of detections:", len(points))

if points:
    print("First detection:", points[0])
else:
    print("No detections returned.")


from services.historical_service import (
    FIRMS_MAP_KEY,
    fetch_historical_data,
    group_unique_fires
)
unique_points, unique_count , fire_summaries = group_unique_fires(points)

print("Total detections:", len(points))
print("Unique fires:", unique_count)

for point in unique_points:
    print(
        "Fire ID:", point["unique_fire_id"],
        "Location:", point["latitude"], point["longitude"]
    )

    print("Unique fires:", unique_count)

for fire in fire_summaries:
    print("\nFire:", fire["unique_fire_id"])
    print("Location:", fire["latitude"], fire["longitude"])
    print("First seen:", fire["first_seen"])
    print("Last seen:", fire["last_seen"])
    print("Detections:", fire["detections_count"])
    print("Max FRP:", fire["max_frp"])


def make_test_point(lat, lon, date, time):
    return {
        "latitude": lat,
        "longitude": lon,
        "frp": 5.0,
        "confidence": "80",
        "acq_date": date,
        "acq_time": time,
        "source": "TEST"
    }


# Test 1: 400 meters and 6 hours
test_1 = [
    make_test_point(30.0000, 31.0000, "2026-11-01", "0600"),
    make_test_point(30.0036, 31.0000, "2026-11-01", "1200")
]

# Test 2: 600 meters
test_2 = [
    make_test_point(30.0000, 31.0000, "2026-11-01", "0600"),
    make_test_point(30.0054, 31.0000, "2026-11-01", "0700")
]

# Test 3: 400 meters and 13 hours
test_3 = [
    make_test_point(30.0000, 31.0000, "2026-11-01", "0600"),
    make_test_point(30.0036, 31.0000, "2026-11-01", "1900")
]


for number, test_points in enumerate(
    [test_1, test_2, test_3], start=1
):
    _, count, fires = group_unique_fires(test_points)

    print(f"\nTEST {number}")
    print("Unique fires:", count)
    print("Expected:", 1 if number == 1 else 2)

    print("RESULT:", "PASS" if count == (1 if number == 1 else 2) else "FAIL")