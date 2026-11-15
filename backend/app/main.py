from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from .database import get_db
from .schemas import ProfileCreate, RationResponse
from .ml_service import predict_kbju, classify_diet

app = FastAPI(title="Nutrition Recommendation System API")


@app.get("/")
def read_root():
    return {"message": "Добро пожаловать в API системы рекомендаций питания!"}


@app.post("/api/generate_ration", response_model=RationResponse)
def generate_ration(profile: ProfileCreate, db: Session = Depends(get_db)):
    try:
        # 1. Прогноз КБЖУ через ML
        kbju = predict_kbju(profile.model_dump())

        # 2. Классификация типа рациона
        diet_type = classify_diet(profile.model_dump())

        # 3. Сохранение рациона в БД (упрощенно, без привязки к user_id, так как его нет в запросе)
        # В реальности здесь был бы user_id из токена авторизации
        insert_ration = text("""
            INSERT INTO rations (profile_id, target_calories, target_proteins, target_fats, target_carbs, diet_type)
            VALUES (1, :cal, :prot, :fat, :carb, :diet)
            RETURNING ration_id;
        """)
        result = db.execute(insert_ration, {
            "cal": kbju["target_calories"],
            "prot": kbju["target_proteins"],
            "fat": kbju["target_fats"],
            "carb": kbju["target_carbs"],
            "diet": diet_type
        })
        ration_id = result.fetchone()[0]
        db.commit()

        # 4. Подбор продуктов (SQL-запрос из ЛР5)
        # Ищем продукты, подходящие под тип рациона и исключающие аллергены (для простоты берем профиль 1)
        products_query = text("""
            SELECT p.product_id, p.name, p.proteins, p.calories
            FROM products p
            WHERE p.proteins >= 10.0 AND p.usefulness_score >= 5.0
              AND p.product_id NOT IN (
                  SELECT pa.product_id FROM product_allergens pa
                  JOIN profile_allergies ua ON pa.allergy_id = ua.allergy_id
                  WHERE ua.profile_id = 1
              )
            ORDER BY p.usefulness_score DESC LIMIT 5;
        """)
        products_result = db.execute(products_query).fetchall()
        products = [{"id": row[0], "name": row[1], "proteins": float(row[2])} for row in products_result]

        return {
            "ration_id": ration_id,
            "target_calories": kbju["target_calories"],
            "target_proteins": kbju["target_proteins"],
            "target_fats": kbju["target_fats"],
            "target_carbs": kbju["target_carbs"],
            "diet_type": diet_type,
            "products": products
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))