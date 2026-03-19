-- =========================================
-- SMS Campaign Attribution Pipeline
-- =========================================

-- 1. Clean & Deduplicate SMS Data
WITH clean_sms AS (
  SELECT
    SendDate,
    TO_HEX(SHA256(CAST(Phone AS STRING))) AS phone_id,
    Activity,
    RANK() OVER (PARTITION BY Phone ORDER BY SendDate) AS rn
  FROM `sms_campaign_raw`
  WHERE SendDate IS NOT NULL
),
sms AS (
  SELECT * FROM clean_sms WHERE rn = 1
),

-- 2. Match SMS → Signup (1-month attribution)
signup_match AS (
  SELECT
    s.*,
    emp.signup_date,
    emp.user_id
  FROM sms s
  LEFT JOIN `user_table` emp
    ON s.phone_id = emp.phone_id
    AND s.SendDate BETWEEN DATE_SUB(emp.signup_date, INTERVAL 30 DAY)
                       AND emp.signup_date
),

-- 3. Add Registration
lifecycle AS (
  SELECT
    m.*,
    r.regist_date,
    CASE WHEN m.signup_date IS NOT NULL THEN 1 ELSE 0 END AS signed_up,
    CASE WHEN r.regist_date IS NOT NULL THEN 1 ELSE 0 END AS registered
  FROM signup_match m
  LEFT JOIN `registration_table` r
    ON m.user_id = r.user_id
),

-- 4. KPI Metrics
kpi AS (
  SELECT
    DATE_TRUNC(SendDate, MONTH) AS month,
    COUNT(DISTINCT phone_id) AS total_users,
    COUNT(DISTINCT IF(signed_up = 1, phone_id, NULL)) AS signed_up_users,
    COUNT(DISTINCT IF(registered = 1, phone_id, NULL)) AS registered_users,
    ROUND(COUNT(DISTINCT IF(signed_up = 1, phone_id, NULL)) 
          / COUNT(DISTINCT phone_id) * 100, 1) AS conversion_rate,
    ROUND(COUNT(DISTINCT IF(registered = 1, phone_id, NULL)) 
          / COUNT(DISTINCT IF(signed_up = 1, phone_id, NULL)) * 100, 1) AS registration_rate
  FROM lifecycle
  GROUP BY 1
),

-- 5. Lead Time
lead_time AS (
  SELECT
    DATE_DIFF(regist_date, signup_date, DAY) AS days_to_register
  FROM lifecycle
  WHERE regist_date IS NOT NULL
)

SELECT * FROM kpi;
