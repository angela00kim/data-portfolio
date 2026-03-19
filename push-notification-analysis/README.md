# Push Notification Analysis

## Overview

Analyzed large-scale push notification data to identify user engagement patterns and optimize notification strategy. Python was used to preprocess raw data that was too large to be handled directly, and Excel was used for exploratory analysis.

## Context

Push notification logs were stored in large raw files that could not be opened or analyzed directly. This made it difficult to evaluate:

* user engagement trends
* notification fatigue
* effectiveness of notification frequency

## Approach

* Used Python to preprocess and segment raw push notification data into smaller, analyzable datasets

* Structured data by user and notification type to enable downstream analysis

* Exported processed datasets for analysis in Excel

* In Excel:

  * analyzed engagement trends over time
  * identified drop-off patterns in notification response
  * compared performance across notification logic types

## Key Insight

Identified a decline in engagement after repeated notifications, indicating notification fatigue and the need to adjust send frequency.

## Impact

* Improved push notification read rates by **76%** through optimized notification strategy
* Maintained effectiveness of preventive maintenance notifications while reducing overexposure

## Tools

* Python (data preprocessing)
* Excel (analysis and visualization)

## Files

* `data_preprocessing.py` — Python script used to clean and segment raw notification data
