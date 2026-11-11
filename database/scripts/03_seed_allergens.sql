INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Лактоза' AND p.category = 'Молочные_яйца' AND p.name NOT ILIKE '%яйцо%'
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Яйца' AND p.name ILIKE '%яйцо%'
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Орехи' AND p.category = 'Орехи'
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Рыба' AND p.category = 'Рыба'
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Соя' AND p.name ILIKE '%соя%'
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Глютен' AND (
    p.name ILIKE '%пшениц%' OR p.name ILIKE '%рож%' OR p.name ILIKE '%ячмен%' 
    OR p.name ILIKE '%овсян%' OR p.name ILIKE '%овёс%' OR p.name ILIKE '%овес%' 
    OR p.name ILIKE '%хлеб%' OR p.name ILIKE '%батон%' OR p.name ILIKE '%макарон%' 
    OR p.name ILIKE '%мука%' OR p.name ILIKE '%булгур%' OR p.name ILIKE '%кус-кус%'
)
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Моллюски и ракообразные' AND (
    p.name ILIKE '%креветк%' OR p.name ILIKE '%краб%' OR p.name ILIKE '%мидии%' 
    OR p.name ILIKE '%устриц%' OR p.name ILIKE '%кальмар%' OR p.name ILIKE '%осьминог%' 
    OR p.name ILIKE '%лобстер%' OR p.name ILIKE '%раки%'
)
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Мёд' AND p.name ILIKE '%мед%'
ON CONFLICT DO NOTHING;

INSERT INTO product_allergens (product_id, allergy_id)
SELECT p.product_id, a.allergy_id FROM products p, allergies a
WHERE a.name = 'Цитрусовые' AND (
    p.name ILIKE '%апельсин%' OR p.name ILIKE '%лимон%' OR p.name ILIKE '%мандарин%' 
    OR p.name ILIKE '%грейпфрут%' OR p.name ILIKE '%помело%' OR p.name ILIKE '%лайм%'
)
ON CONFLICT DO NOTHING;