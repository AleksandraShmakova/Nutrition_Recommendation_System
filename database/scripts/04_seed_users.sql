INSERT INTO users (login, password_hash) VALUES
('test_user_1', 'hash_abc123'),
('test_user_2', 'hash_def456');

INSERT INTO profiles (user_id, age, height, weight, gender, goal, activity_level, has_diabetes)
VALUES 
(1, 30, 170.0, 80.0, 'male', 'похудение', 1.375, FALSE),
(2, 25, 165.0, 55.0, 'female', 'набор массы', 1.55, TRUE);

INSERT INTO profile_allergies (profile_id, allergy_id)
SELECT 1, allergy_id FROM allergies WHERE name = 'Лактоза';

INSERT INTO profile_allergies (profile_id, allergy_id)
SELECT 2, allergy_id FROM allergies WHERE name IN ('Орехи', 'Глютен');

INSERT INTO user_preferences (profile_id, preference_type, preference_value) VALUES
(1, 'diet', 'сбалансированный'),
(2, 'diet', 'высокобелковый'),
(2, 'exclude_category', 'Сладости');