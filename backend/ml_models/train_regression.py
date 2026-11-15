import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, HistGradientBoostingRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import StandardScaler
from sklearn.neural_network import MLPRegressor
import joblib
import os

DATA_PATH = 'nhanes_regression_final.csv'
MODEL_DIR = 'models/'

if not os.path.exists(MODEL_DIR):
    os.makedirs(MODEL_DIR)

print("1. Загрузка данных...")
df = pd.read_csv(DATA_PATH, sep=';', decimal=',')
df = df.dropna()
df = df[(df['target_calories'] > 800) & (df['target_calories'] < 4000)]  # Убираем выбросы
print(f"   Осталось {len(df)} записей.")

# ==========================================
# FEATURE ENGINEERING (Создаем новые признаки)
# ==========================================
print("2. Создание новых признаков...")
X = df[['age', 'height_cm', 'weight_kg', 'bmi', 'sedentary_min_day']].copy()

# Взаимодействия
X['weight_height_ratio'] = X['weight_kg'] / (X['height_cm'] ** 2)  # Уточненный ИМТ
X['age_weight'] = X['age'] * X['weight_kg']
X['activity_level'] = 1.2 + (X['sedentary_min_day'] / 1000)  # Эмуляция коэффициента активности

# Категориальные признаки
X['gender'] = df['gender'].apply(lambda x: 0 if x == 'male' else 1)
X = pd.concat([X, pd.get_dummies(df['race'], prefix='race')], axis=1)

y = df[['target_calories', 'target_protein_g', 'target_fat_g', 'target_carbs_g']]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Масштабирование для нейросети
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# ==========================================
# ТЕСТИРУЕМ МОДЕЛИ
# ==========================================
models = {
    "HistGradientBoosting": MultiOutputRegressor(
        HistGradientBoostingRegressor(max_iter=200, learning_rate=0.05, max_depth=5, random_state=42)),
    "Deep NeuralNetwork": MultiOutputRegressor(
        MLPRegressor(hidden_layer_sizes=(128, 64, 32), activation='relu', solver='adam', max_iter=1500,
                     random_state=42))
}

best_model = None
best_mae = float('inf')
best_name = ""

print("\n3. Обучение и сравнение моделей...")
for name, model in models.items():
    print(f"--- Тестируем: {name} ---")

    if "NeuralNetwork" in name:
        model.fit(X_train_scaled, y_train)
        y_pred = model.predict(X_test_scaled)
    else:
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)

    mae = mean_absolute_error(y_test, y_pred)
    print(f"    MAE = {mae:.2f} ккал")

    if mae < best_mae:
        best_mae = mae
        best_model = model
        best_name = name

# Сравнение с формулой
print("\n4. Сравнение с формулой...")
formula_calories = []
for idx, row in X_test.iterrows():
    weight, height, age = row['weight_kg'], row['height_cm'], row['age']
    if row['gender'] == 0:  # male
        bmr = 10 * weight + 6.25 * height - 5 * age + 5
    else:
        bmr = 10 * weight + 6.25 * height - 5 * age - 161

    # Учитываем активность
    formula_calories.append(bmr * row['activity_level'])

mae_formula = mean_absolute_error(y_test['target_calories'], formula_calories)

print("\n" + "=" * 50)
print(f"ПОБЕДИТЕЛЬ: {best_name}")
print(f"MAE ML-модели: {best_mae:.2f} ккал")
print(f"MAE формулы:   {mae_formula:.2f} ккал")
print(f"ML лучше формулы на {mae_formula - best_mae:.2f} ккал ({(mae_formula - best_mae) / mae_formula * 100:.1f}%)")
print("=" * 50)

# Сохраняем
joblib.dump(best_model, os.path.join(MODEL_DIR, 'kbju_regressor_best.pkl'))
joblib.dump(scaler, os.path.join(MODEL_DIR, 'scaler.pkl'))
joblib.dump(X.columns.tolist(), os.path.join(MODEL_DIR, 'model_features.pkl'))
print(f"\n5. Модель сохранена в {MODEL_DIR}")