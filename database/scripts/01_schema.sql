CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    login VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    age INTEGER CHECK (age >= 14 AND age <= 120),
    height NUMERIC(5,2) CHECK (height > 0),
    weight NUMERIC(5,2) CHECK (weight > 0),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female')),
    race VARCHAR(50) DEFAULT 'other_race', -- <-- НОВАЯ СТРОКА
    goal VARCHAR(50) CHECK (goal IN ('похудение', 'набор массы', 'поддержание')) DEFAULT 'поддержание',
    activity_level NUMERIC(3,2) DEFAULT 1.2 CHECK (activity_level >= 1.0 AND activity_level <= 2.5),
    has_diabetes BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE allergies (
    allergy_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE profile_allergies (
    profile_id INTEGER REFERENCES profiles(profile_id) ON DELETE CASCADE,
    allergy_id INTEGER REFERENCES allergies(allergy_id) ON DELETE CASCADE,
    PRIMARY KEY (profile_id, allergy_id)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sample_type VARCHAR(20) CHECK (sample_type IN ('Обучающая', 'Тестовая')) DEFAULT 'Обучающая',
    category VARCHAR(100) NOT NULL DEFAULT 'Без категории',
    calories NUMERIC(7,2) CHECK (calories >= 0) DEFAULT 0,
    proteins NUMERIC(6,2) CHECK (proteins >= 0) DEFAULT 0,
    unsaturated_fats NUMERIC(6,2) CHECK (unsaturated_fats >= 0) DEFAULT 0,
    saturated_fats NUMERIC(6,2) CHECK (saturated_fats >= 0) DEFAULT 0,
    complex_carbs NUMERIC(6,2) CHECK (complex_carbs >= 0) DEFAULT 0,
    fiber NUMERIC(6,2) CHECK (fiber >= 0) DEFAULT 0,
    sugar NUMERIC(6,2) CHECK (sugar >= 0) DEFAULT 0,
    vitamin_c NUMERIC(8,2) CHECK (vitamin_c >= 0) DEFAULT 0,
    vitamin_a NUMERIC(8,2) CHECK (vitamin_a >= 0) DEFAULT 0,
    vitamin_b1 NUMERIC(6,3) CHECK (vitamin_b1 >= 0) DEFAULT 0,
    calcium NUMERIC(7,2) CHECK (calcium >= 0) DEFAULT 0,
    iron NUMERIC(6,2) CHECK (iron >= 0) DEFAULT 0,
    potassium NUMERIC(8,2) CHECK (potassium >= 0) DEFAULT 0,
    magnesium NUMERIC(7,2) CHECK (magnesium >= 0) DEFAULT 0,
    cholesterol NUMERIC(7,2) CHECK (cholesterol >= 0) DEFAULT 0,
    water NUMERIC(5,2) CHECK (water >= 0 AND water <= 100) DEFAULT 0,
    usefulness_score NUMERIC(6,2) CHECK (usefulness_score >= 0 AND usefulness_score <= 100) DEFAULT 0
);

CREATE TABLE product_allergens (
    product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    allergy_id INTEGER REFERENCES allergies(allergy_id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, allergy_id)
);

CREATE TABLE meal_types (
    meal_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE user_preferences (
    preference_id SERIAL PRIMARY KEY,
    profile_id INTEGER NOT NULL REFERENCES profiles(profile_id) ON DELETE CASCADE,
    preference_type VARCHAR(50) NOT NULL 
        CHECK (preference_type IN ('diet', 'exclude_category', 'exclude_product', 'max_sugar')),
    preference_value VARCHAR(100) NOT NULL,
    UNIQUE (profile_id, preference_type, preference_value)
);

CREATE TABLE rations (
    ration_id SERIAL PRIMARY KEY,
    profile_id INTEGER NOT NULL REFERENCES profiles(profile_id) ON DELETE CASCADE,
    target_calories NUMERIC(7,2) CHECK (target_calories > 0),
    target_proteins NUMERIC(6,2) CHECK (target_proteins > 0),
    target_fats NUMERIC(6,2) CHECK (target_fats > 0),
    target_carbs NUMERIC(6,2) CHECK (target_carbs > 0),
    diet_type VARCHAR(50) CHECK (diet_type IN ('низкоуглеводный', 'сбалансированный', 'высокобелковый')) DEFAULT 'сбалансированный',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ration_products (
    ration_id INTEGER REFERENCES rations(ration_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id) ON DELETE CASCADE,
    meal_type_id INTEGER REFERENCES meal_types(meal_type_id),
    amount_grams NUMERIC(7,2) CHECK (amount_grams > 0),
    PRIMARY KEY (ration_id, product_id, meal_type_id)
);

CREATE TABLE ration_recipes (
    id SERIAL PRIMARY KEY,
    ration_id INTEGER NOT NULL REFERENCES rations(ration_id) ON DELETE CASCADE,
    meal_type_id INTEGER REFERENCES meal_types(meal_type_id),
    title VARCHAR(255) NOT NULL,
    source_url VARCHAR(500),
    instructions TEXT,
    ingredients_json JSONB DEFAULT '[]'
);

CREATE TABLE ration_feedback (
    feedback_id SERIAL PRIMARY KEY,
    ration_id INTEGER NOT NULL REFERENCES rations(ration_id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_usefulness ON products(usefulness_score DESC);
CREATE INDEX idx_rations_profile ON rations(profile_id);
CREATE INDEX idx_ration_recipes_ration ON ration_recipes(ration_id);
CREATE INDEX idx_user_preferences_profile ON user_preferences(profile_id);
CREATE INDEX idx_ration_feedback_ration ON ration_feedback(ration_id);