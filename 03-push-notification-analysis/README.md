# Push Notification Optimization – LG ThinQ

## Overview
Analyzed 2.93M push notifications over a 2-year period to identify engagement gaps and redesign notification strategy, resulting in a 76% increase in read rates.

## Business Problem
Push notifications for appliance maintenance (e.g., dryer duct cleaning, water temperature issues, filter replacement) showed consistently low engagement, despite being critical for product performance and customer satisfaction.

Challenges included:
- Low visibility and user awareness  
- Repeated notifications with declining engagement  
- No tracking of customer-level exposure or behavior over time  

## Data Challenges
- Raw data distributed across multiple large CSV files (not Excel-readable)  
- Mixed encodings (UTF-8 / UTF-16)  
- Granular, inconsistent diagnosis codes  
- No standardized product or engagement labels  

## Data Processing (Python)
- Ingested and consolidated large-scale datasets using Python (Pandas)  
- Standardized product categories across 7 appliance types  
- Grouped 20+ diagnosis codes into unified notification logic categories  
- Derived engagement status (read vs. unread) from delivery flags  
- Built time-based features (month, year, YYYYMM) for trend analysis  
- Filtered known bad data windows (Feb 5–17, 2024)  

## Key Insights

### Notification fatigue
- Read rates declined significantly after 3 repeated notifications  
- Repeated exposure led to progressively lower engagement  

### Low baseline engagement
- Many notification types had read rates below 17%  
- Some logics performed significantly worse  

### Gap between detection and action
- System correctly detected issues  
- Users ignored notifications due to:
  - unclear messaging  
  - lack of urgency  
  - notification overload  

## Validation and User Research
- Conducted 3 rounds of customer surveys (~4K responses)  
- Identified key drivers of disengagement:
  - notification fatigue across apps and devices  
  - low perceived urgency  
  - unclear instructions  

- Performed field validation (10 customers) to confirm:
  - detection accuracy  
  - mismatch between alerts and user action  

## Solution
Implemented system-level optimizations:

- Suppression logic to reduce repeated exposure  
- Content redesign to improve clarity and actionability  
- Time zone–based delivery to improve visibility  
- Grouped notifications to minimize notification overload  

## Impact
- 76% increase in push notification read rate  

## Tech Stack
- Python (Pandas)  
- Data preprocessing and transformation  
- Behavioral analysis  

## Note
- Raw data and full analysis are not included due to confidentiality  
- This repository focuses on the data preprocessing and analytical foundation of the project  
