-- =========================================
-- Exchange Recommendation Engine (Core Logic)
-- =========================================

-- =========================================
-- 1. Feature Engineering (Model Parsing)
-- =========================================
WITH base AS (
    SELECT product, UPPER(model) AS model, ra_cnt
    FROM Parts.ra_raw
),

features AS (
    SELECT *,
           CONCAT(REGEXP_EXTRACT(model, "[a-zA-Z._%+-]+"), REGEXP_EXTRACT(model, r"([0-9]+)")) AS model_type,
           CASE 
               WHEN LENGTH(CONCAT(REGEXP_EXTRACT(model, "[a-zA-Z._%+-]+"), REGEXP_EXTRACT(model, r"([0-9]+)"))) < 5
               THEN UPPER(LEFT(model, LENGTH(model)-1))
               ELSE CONCAT(REGEXP_EXTRACT(model, "[a-zA-Z._%+-]+"), REGEXP_EXTRACT(model, r"([0-9]+)"))
           END AS normalized_model,
           CASE
               WHEN model LIKE "%OLED%" OR model LIKE "%LX%" THEN "OLED"
               WHEN model LIKE "%NANO%" THEN "NANO"
               WHEN model LIKE "%QNED%" THEN "QNED"
               ELSE "STANDARD"
           END AS type,
           RIGHT(model,1) AS color_code
    FROM base
),

-- =========================================
-- 2. Join Pricing + Dimensions
-- =========================================
combined AS (
    SELECT a.product, a.model, a.model_type, a.normalized_model, a.type, a.color_code,
           b.msrp, b.capacity, b.width, b.height, b.depth,
           b.msrp - 100 AS lower, b.msrp + 300 AS upper
    FROM features a
    LEFT JOIN Parts.cost_raw b ON a.model = b.model
),

-- =========================================
-- 3. Candidate Matching
-- =========================================
matches AS (
    SELECT a.model, a.product, a.type, a.color_code, a.msrp, a.capacity, a.width, a.height, a.depth,
           b.model AS candidate_model, b.type AS candidate_type, b.color_code AS candidate_color,
           b.msrp AS candidate_msrp, b.capacity AS candidate_capacity,
           
           CASE 
               -- exact match
               WHEN a.model = b.model THEN 0

               -- same model family + price range
               WHEN b.msrp BETWEEN a.lower AND a.upper AND a.model_type = b.model_type THEN 1

               -- same color
               WHEN a.color_code = b.color_code THEN 2

               -- similar capacity + dimension tolerance
               WHEN ABS(b.capacity - a.capacity) <= 2
                    AND b.width BETWEEN a.width - 1 AND a.width + 1
                    AND b.height BETWEEN a.height - 1 AND a.height + 1
                    AND b.depth BETWEEN a.depth - 1 AND a.depth + 1 THEN 3

               -- fallback: same product type
               WHEN a.type = b.type THEN 4

               ELSE 5
           END AS similarity_score

    FROM combined a
    JOIN combined b 
        ON a.product = b.product
    WHERE a.model != b.model
),

-- =========================================
-- 4. Ranking Logic
-- =========================================
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY model
               ORDER BY similarity_score,
                        ABS(candidate_msrp - msrp),
                        ABS(candidate_capacity - capacity)
           ) AS rank
    FROM matches
)

-- =========================================
-- 5. Final Output
-- =========================================
SELECT model, candidate_model AS recommended_model, similarity_score, rank
FROM ranked
WHERE rank <= 5
ORDER BY model, rank;
