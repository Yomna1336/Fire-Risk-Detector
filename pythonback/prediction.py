import os
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
import joblib

def fetch_nasa_firms_data():
    csv_file = 'nasa_firms_active_fires.csv'
    if not os.path.exists(csv_file):
        print("جاري تحميل أحدث بيانات بؤر الحرائق من أقمار ناسا...")
        url = "https://firms.modaps.eosdis.nasa.gov/data/active_fire/c6/csv/MODIS_C6_Global_7d.csv"
        try:
            df = pd.read_csv(url)
            df.to_csv(csv_file, index=False)
            print("تم تحميل البيانات الحقيقية بنجاح وحفظها محلياً.")
        except Exception as e:
            print(f"تعذر الاتصال المباشر بالرابط، يتم إنشاء بيانات محاكاة واقعية تتضمن المواقع والبيئة...")
            np.random.seed(42)
            n = 5000
            df = pd.DataFrame({
                'latitude': np.random.uniform(20.0, 35.0, n),
                'longitude': np.random.uniform(30.0, 50.0, n),
                'temperature': np.random.uniform(15.0, 45.0, n),
                'humidity': np.random.uniform(10.0, 90.0, n),
                'wind_speed': np.random.uniform(0.0, 40.0, n),
                'ndvi': np.random.uniform(0.1, 0.9, n), # مؤشر الغطاء النباتي
                'confidence': np.random.randint(20, 100, n)
            })
            df.to_csv(csv_file, index=False)
    else:
        print(f"جاري قراءة البيانات من الملف المحلي: {csv_file}")
        df = pd.read_csv(csv_file)
    return df

def train_model():
    df = fetch_nasa_firms_data()
    
    # تحديد الميزات التي تشمل الموقع الجغرافي والعوامل البيئية
    features = ['latitude', 'longitude', 'temperature', 'humidity', 'wind_speed', 'ndvi']
    
    # تنظيف البيانات الناقصة إن وجدت
    df = df.dropna(subset=[col for col in features if col in df.columns])
    
    X = df[['latitude', 'longitude', 'temperature', 'humidity', 'wind_speed', 'ndvi']]
    y = (df['confidence'] > 70).astype(int) # هدف التنبؤ: 1 خطر مرتفع، 0 آمن
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print("--- جاري تدريب نموذج الذكاء الاصطناعي بناءً على الموقع والعوامل البيئية ---")
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    print("\n--- تقرير دقة النموذج ---")
    print(classification_report(y_test, y_pred))
    
    # حفظ النموذج المدرب
    model_file = 'wildfire_model.pkl'
    joblib.dump(model, model_file)
    print(f"\nتم حفظ النموذج بنجاح في الملف: {model_file}")

if __name__ == '__main__':
    train_model()