import joblib
import numpy as np
import os
import pandas as pd

MODEL_DIR = os.path.join(os.path.dirname(__file__), '..', 'ml_models', 'models')

print("Загрузка ML-модели...")
try:
    regressor = joblib.load(os.path.join(MODEL_DIR, 'kbju_regressor_best.pkl'))
    scaler = joblib.load(os.path.join(MODEL_DIR, 'scaler.pkl'))
    features = joblib.load(os.path.join(MODEL_DIR, 'model_features.pkl'))
    print(f"Модель успешно загружена! Ожидает {len(features)} признаков.")
    print(f"Порядок признаков: {features}")
except Exception as e:
    print(f"ОШИБКА загрузки модели: {e}")
    regressor = None
    scaler = None


def predict_kbju(profile_data: dict):
    if regressor is None or scaler is None:
        raise Exception("ML-модель или скалер не загружены")

    height_m = profile_data['height_cm'] / 100
    weight = profile_data['weight_kg']
    age = profile_data['age']
    bmi = weight / (height_m ** 2)
    gender_encoded = 0 if profile_data['gender'] == 'male' else 1

    input_dict = {
        'age': age,
        'height_cm': profile_data['height_cm'],
        'weight_kg': weight,
        'bmi': bmi,
        'sedentary_min_day': 300,
        'gender': gender_encoded,
        'weight_height_ratio': weight / (profile_data['height_cm'] ** 2),
        'age_weight': age * weight,
        'activity_level': 1.2 + (300 / 1000)
    }

    race = profile_data.get('race', 'other_race')
    for col in features:
        if col.startswith('race_'):
            input_dict[col] = 0
    race_col = f'race_{race}'
    if race_col in features:
        input_dict[race_col] = 1

    # --- САМОЕ ВАЖНОЕ: берем порядок из скалера ---
    if hasattr(scaler, 'feature_names_in_'):
        scaler_order = scaler.feature_names_in_
    else:
        scaler_order = features  # fallback

    input_df = pd.DataFrame([input_dict])
    input_df = input_df[scaler_order]  # Приводим к порядку скалера
    input_df = input_df.fillna(0).astype(float)

    # Масштабируем
    input_scaled = scaler.transform(input_df)

    prediction = regressor.predict(input_scaled)[0]

    print(f"Сырое предсказание: {prediction}")

    # Защита от бреда (на всякий случай)
    cal = max(800.0, min(float(prediction[0]), 4000.0))
    prot = max(20.0, min(float(prediction[1]), 300.0))
    fat = max(10.0, min(float(prediction[2]), 200.0))
    carb = max(20.0, min(float(prediction[3]), 600.0))

    return {
        "target_calories": round(cal, 2),
        "target_proteins": round(prot, 2),
        "target_fats": round(fat, 2),
        "target_carbs": round(carb, 2)
    }

def classify_diet(profile_data: dict):
    weight = profile_data['weight_kg']
    height = profile_data['height_cm']
    goal = profile_data['goal']
    has_diabetes = profile_data['has_diabetes']

    bmi = weight / ((height / 100) ** 2)

    if has_diabetes:
        return "низкоуглеводный"
    elif bmi > 30 and goal == "похудение":
        return "низкоуглеводный"
    elif goal == "набор массы" or bmi < 18.5:
        return "высокобелковый"
    else:
        return "сбалансированный"