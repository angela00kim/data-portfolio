# Push Notification Optimization – Data Preprocessing (Python)

## Context
At LG Electronics, I analyzed 2.93M push notifications sent to ThinQ app 
users to identify engagement patterns and optimize notification strategy — 
resulting in a **76% increase in read rates**.

The full analysis was conducted in Excel/BigQuery on proprietary data. 
This repository contains the Python preprocessing pipeline I built to 
handle the data at a scale Excel alone could not manage.

## What Problem This Solved
Raw notification data arrived as dozens of fragmented CSV exports with 
inconsistent encodings, granular diagnosis codes, and no standardized 
product or engagement labels. Before any analysis could happen, the data 
needed to be consolidated, cleaned, and restructured.

## What This Script Does
- Combines and ingests multiple large CSV files with mixed encodings (UTF-8/UTF-16)
- Standardizes product categories across 7 appliance types
- Groups 20+ granular diagnosis codes into analyzable notification logic types
- Derives engagement status (Read vs. Unread) from raw delivery flags
- Extracts date dimensions (month, year, YYYYMM) for trend analysis
- Filters a known bad data window (Feb 5–17, 2024)
- Splits output into separate files per logic type for downstream analysis

## Why Python Instead of Excel
The dataset contained 2.93M+ rows across multiple files — beyond Excel's 
row limit and too slow for manual processing. Python (Pandas) enabled 
automated, repeatable ingestion that fed directly into the analysis layer.

## Tools
Python, Pandas

## Note
Raw data and final analysis are not included due to company data 
confidentiality. This script represents the preprocessing layer of a 
larger end-to-end analytics workflow.
