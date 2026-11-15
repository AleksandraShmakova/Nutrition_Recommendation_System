from pydantic import BaseModel

class ProfileCreate(BaseModel):
    age: int
    height_cm: float
    weight_kg: float
    gender: str
    race: str = "other_race"
    goal: str
    has_diabetes: bool = False

class RationResponse(BaseModel):
    ration_id: int
    target_calories: float
    target_proteins: float
    target_fats: float
    target_carbs: float
    diet_type: str
    products: list