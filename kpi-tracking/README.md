# KPI Tracking Pipeline

## Overview

Built a SQL-based KPI pipeline to track core business metrics across product usage, customer engagement, and service performance. The pipeline consolidates multiple data sources into a unified table used for executive dashboard reporting.

## Problem

Key metrics (sales, device connectivity, registration, app performance, and service quality) were stored across separate systems with inconsistent definitions. This made it difficult to monitor performance and identify trends across the full customer lifecycle.

## Approach

* Aggregated and standardized metrics across multiple domains:

  * **Sales** (volume)
  * **Connected Devices** (volume, connection rate)
  * **Registered Devices** (volume, registration rate)
  * **Push Notifications** (read rate)
  * **App Ratings** (AOS, iOS)
  * **Customer Care QOS** (email, push, agent performance)

* Built time-based metrics at both **monthly and weekly levels**

* Modeled relationships between datasets (e.g., connected → registered rates)

* Applied window functions (`SUM OVER`, `LAG`) to compute:

  * cumulative metrics
  * period-over-period changes

## Output

Generated a unified KPI table supporting:

* multiple product groups (Total, TV, H&A)
* multiple metric types (volume, rate)
* multiple time granularities (monthly, weekly)

This table serves as the backend for executive dashboards and recurring business reviews.

## Key SQL Concepts

* Window functions: `LAG`, `SUM OVER`
* Time-based aggregation: `DATE_TRUNC`
* Multi-source joins across product, app, and service datasets
* Metric standardization across domains

## Files

* `kpi_pipeline.sql` — core pipeline logic for KPI table generation
