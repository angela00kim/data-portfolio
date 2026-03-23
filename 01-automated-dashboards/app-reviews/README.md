# App Rating & Reviews Analytics

## Overview

Designed and implemented a SQL-based pipeline to transform unstructured app review data into a standardized, analysis-ready dataset.
This system replaced a manual tagging workflow and enabled scalable, repeatable reporting of customer feedback for product and engineering teams.

## Business Problem

Customer reviews were tagged by call center agents, but:

* Tagging was inconsistent across agents
* Data existed in multiple fragmented structures (A/B/C case formats)
* Manual cleanup and categorization were required before analysis

A teammate previously spent **15+ hours per week manually cleaning and tagging data in Excel**, limiting the ability to generate timely insights or build structured reports.

## Solution

Built an automated pipeline to normalize, standardize, and structure review data into a unified VOC dataset.

### Key Components

* **Multi-structure ingestion**

  * Unified A/B/C case data into a single dataset using `UNION ALL`

* **Category standardization**

  * Normalized inconsistent Level 1/2/3 tags across agents
  * Resolved naming inconsistencies (e.g., “Product SW Udate” → “Product SW Update”)

* **Platform mapping**

  * Standardized app sources (iOS vs Android)

* **Data cleaning & validation**

  * Handled nulls, blanks, and invalid category combinations
  * Enforced consistent hierarchy across categories

* **Time-based modeling**

  * Generated monthly and weekly labels for trend analysis

## Output & Usage

Produced structured datasets that directly power dashboard visualizations, including:

* App rating trends (iOS vs Android)
* Review volume trends
* Issue breakdown by category (Level 1 / 2 / 3)
* Recurring product and app issues

The dataset is structured to **mirror dashboard layouts**, enabling:

* Rapid creation of reporting slides
* Consistent formatting across monthly reports
* Faster escalation of issues to app development teams

As a result, reporting shifted from manual data preparation to **direct visualization and stakeholder communication**.

## Dashboard
![Dashboard Screenshot](images/app_rating_reviews.png)
![Dashboard Screenshot](images/app_reviews_breakdown.png)


## Impact

* Eliminated manual Excel-based tagging workflow (~15+ hrs/week saved)
* Enabled scalable and consistent analysis of customer feedback
* Accelerated reporting cycles and issue escalation to product teams
* Improved alignment between customer feedback and engineering priorities

## Key SQL Concepts

* Data normalization across heterogeneous input structures (`UNION ALL`)
* Conditional standardization using `CASE WHEN`
* Hierarchical data modeling (Level 1 / 2 / 3 categories)
* Time-based feature engineering (`FORMAT_TIMESTAMP`, `EXTRACT`)

## Files

* `app_reviews_pipeline.sql` — SQL pipeline for VOC data transformation and standardization


## Notes
* Raw data are not included due to data privacy policies
* Sensitive fields have been anonymized
* Logic and structure are preserved to demonstrate system design and SQL capability

