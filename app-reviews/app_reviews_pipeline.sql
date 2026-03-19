-- =========================================
-- App Ratings & Reviews Pipeline
-- =========================================

-- 1. App Rating (Monthly + Weekly labels)
CREATE OR REPLACE TABLE AppRating.apprating_dup AS
SELECT *, EXTRACT(YEAR FROM Date) AS Year,
       CONCAT(CAST(FORMAT_TIMESTAMP('%Y', Date) AS STRING), "-", CAST(FORMAT_TIMESTAMP('%m', Date) AS STRING)) AS Label,
       "Month" AS Date_Type
FROM AppRating.apprating_raw
WHERE Month IS NOT NULL

UNION ALL

SELECT *, EXTRACT(YEAR FROM Date) AS Year,
       CONCAT(CAST(EXTRACT(YEAR FROM Date) AS STRING), " W", CAST(EXTRACT(ISOWEEK FROM Date) AS STRING)) AS Label,
       "Week" AS Date_Type
FROM AppRating.apprating_raw
WHERE Week IS NOT NULL;


-- =========================================
-- 2. App Reviews (VOC Cleaning + Structuring)
-- =========================================

CREATE OR REPLACE TABLE AppReview.appreview_dup AS
SELECT
  CASE WHEN Account="LG ThinQ Apple" THEN "iOS"
       WHEN Account="LG ThinQ Google Play" THEN "AOS"
       ELSE "" END AS OS,
  Date, Case_Id,

  CASE WHEN Level1="ThinQ App_Product" THEN "ThinQ App Product"
       WHEN Level1="ThinQ App_Main" THEN "ThinQ App Main"
       WHEN Level1="ThinQ App_Service" THEN "ThinQ App Service"
       WHEN Level1="N/A" THEN "Others"
       WHEN Level1=" " THEN NULL
       ELSE Level1 END AS Level1,

  CASE WHEN Level1 IN ("Positive","Proposal","Others","N/A") OR Level1 IS NULL OR Level1=" " THEN ""
       ELSE Level2 END AS Level2,

  CASE WHEN Level3 IS NULL OR Level1 IN ("Proposal","Positive","N/A") THEN ""
       WHEN Level3 IN ("Product SW Udate","Product SW Update") THEN "Product SW Update"
       ELSE Level3 END AS Level3,

  Summary, `Case`, Review, ReviewSummary, Store, AppVersion, PhoneType, OSType2, Product1, Product2, Product3, cnt

FROM (
  SELECT Account, Case_Creation AS Date, Case_Id,
         ThinQ_Level_1_A__Case_ AS Level1, ThinQ_Level_2_A__Case_ AS Level2, ThinQ_Level_3_A__Case_ AS Level3,
         ThinQ_Summary__Case_ AS Summary, `Case`, SUBSTR(`Case`,11) AS Review,
         Ambers_Comments AS ReviewSummary, Social_Network AS Store,
         App_Version__Case_ AS AppVersion, Device__Case_ AS PhoneType, Device_OS__Case_ AS OSType2,
         ThinQ_Product_A__Case_ AS Product1, ThinQ_Product_B__Case_ AS Product2, ThinQ_Product_C__Case_ AS Product3,
         Case_Count__SUM_ AS cnt
  FROM AppReview.appreview_raw

  UNION ALL

  SELECT Account, Case_Creation, Case_Id,
         ThinQ_Level_1_B__Case_, ThinQ_Level_2_B__Case_, ThinQ_Level_3_B__Case_,
         ThinQ_Summary__Case_, `Case`, SUBSTR(`Case`,11),
         Ambers_Comments, Social_Network, App_Version__Case_, Device__Case_, Device_OS__Case_,
         ThinQ_Product_A__Case_, ThinQ_Product_B__Case_, ThinQ_Product_C__Case_, Case_Count__SUM_
  FROM AppReview.appreview_raw

  UNION ALL

  SELECT Account, Case_Creation, Case_Id,
         ThinQ_Level_1_C__Case_, ThinQ_Level_2_C__Case_, ThinQ_Level_3_C__Case_,
         ThinQ_Summary__Case_, `Case`, SUBSTR(`Case`,11),
         Ambers_Comments, Social_Network, App_Version__Case_, Device__Case_, Device_OS__Case_,
         ThinQ_Product_A__Case_, ThinQ_Product_B__Case_, ThinQ_Product_C__Case_, Case_Count__SUM_
  FROM AppReview.appreview_raw
);

-- =========================================
-- 3. Add Time Labels (Month + Week)
-- =========================================

CREATE OR REPLACE TABLE AppReview.appreview_final AS
SELECT *, CONCAT(CAST(FORMAT_TIMESTAMP('%Y', Date) AS STRING), "-", CAST(FORMAT_TIMESTAMP('%m', Date) AS STRING)) AS Label,
       "Month" AS Date_Type
FROM AppReview.appreview_dup

UNION ALL

SELECT *, CONCAT(CAST(EXTRACT(YEAR FROM Date) AS STRING), " W", CAST(EXTRACT(ISOWEEK FROM Date) AS STRING)) AS Label,
       "Week" AS Date_Type
FROM AppReview.appreview_dup;
