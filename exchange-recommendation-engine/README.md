# Exchange Recommendation Engine

## Overview
Built a SQL-based recommendation engine to optimize product exchange decisions and reduce unnecessary buybacks.

This system was developed as part of an executive-sponsored initiative and integrated into an internal tool used by call center agents to guide real-time exchange decisions across multiple product categories.

---

## Business Problem
- High buyback rate (~71%) compared to exchanges (~29%)
- No standardized method to recommend alternative products
- Manual and inconsistent decision-making across agents and product groups

---

## Solution
Developed a recommendation system that generates **top 5 alternative products per model** based on structured similarity logic and business constraints.

The system supports:
- Refrigerator, Washer, Dryer, WashTower, MWO, and TV
- Same-color and different-color recommendations
- Inventory-aware decision making

---

## Recommendation Logic

### Search Criteria
- **Price Range**: -$100 to +$300 from original product  
- **Capacity / Size**:
  - Appliances: comparable capacity  
  - TV: screen size ≥ original  
- **Dimensions**: within ±1 inch (W × H × D)  
- **Product Type**: must match category (e.g., French Door, Top Load, OLED)  
- **Color Options**: same or different  

---

### Ranking Priority

#### Home Appliances (H&A)
1. Same organization code  
2. Same product type  
3. Same color  
4. Price proximity  
5. Capacity / dimension similarity  

#### TV
1. Same organization code  
2. Same product type  
3. Equal or larger screen size  
4. Price proximity  

---

## Approach

### 1. Feature Engineering
- Extracted structured attributes from model names using pattern matching (REGEXP)
- Standardized product types, capacity, and model groupings

### 2. Candidate Filtering
- Filtered valid alternatives based on:
  - price range
  - product compatibility
  - dimension constraints
  - inventory availability

### 3. Ranking & Selection
- Applied prioritization logic using SQL window functions
- Generated **top 5 ranked alternatives per product**

---

## Example Output (Agent View)

The recommendation engine is integrated into an internal tool used by call center agents.

### Washer Example
![Washer Example](screenshots/washer_recommendation_example.png)

### Dryer Example
![Dryer Example](screenshots/dryer_recommendation_example.png)

- Displays top alternative models based on similarity logic  
- Highlights differences in product type, size, and color  
- Enables faster and more consistent exchange decisions  

---

## Impact
- Increased exchange rate from **29% → 45%** (+16pp)
- Reduced unnecessary buybacks
- Estimated **~$151K monthly cost savings**
- Standardized decision-making across product categories

---

## Tech Stack
- SQL (BigQuery)
- Data modeling & transformation
- Window functions & ranking logic

---

## Notes
- Raw data and internal dashboards are not included due to data privacy policies  
- Product identifiers and sensitive fields have been anonymized  
- Logic and structure are preserved to demonstrate system design and SQL capability  
