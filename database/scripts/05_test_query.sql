SELECT p.product_id, p.name, p.proteins, p.calories, p.usefulness_score
FROM products p
WHERE p.proteins >= 10.0
  AND p.usefulness_score >= 5.0
  AND p.product_id NOT IN (
      SELECT pa.product_id FROM product_allergens pa
      JOIN profile_allergies ua ON pa.allergy_id = ua.allergy_id
      WHERE ua.profile_id = 1
  )
  AND p.category NOT IN (
      SELECT preference_value FROM user_preferences
      WHERE profile_id = 1 AND preference_type = 'exclude_category'
  )
ORDER BY p.usefulness_score DESC
LIMIT 10;