## Overview

Built a SQL-based KPI pipeline and dashboard used for monthly and weekly executive reporting. This replaced static Excel reports and is used during leadership meetings to review performance and drill into specific metrics.

# KPI Tracking & Executive Dashboard Pipeline

## Overview

Developed an automated KPI reporting system and executive dashboard that provided real-time visibility into business performance, eliminating reliance on manual Excel-based reporting.

The system enabled leadership, including the subsidiary president, to directly monitor key metrics without waiting for periodic reports.

## Business Problem

KPI reporting was previously:

* Manually compiled in Excel across multiple data sources
* Time-intensive and error-prone
* Delivered on a fixed schedule (weekly/monthly), limiting responsiveness
* Inconsistent across teams due to lack of standardized definitions

This created delays in decision-making and limited visibility into real-time performance.

## Solution

Designed and implemented a centralized SQL-based pipeline and dashboard system to automate KPI tracking and provide direct access to leadership.

### Key Components

* **Data integration**

  * Consolidated multiple data sources into a unified reporting layer

* **KPI standardization**

  * Defined consistent metric logic across teams

* **Automation**

  * Replaced manual Excel workflows with SQL-based pipelines

* **Real-time dashboarding**

  * Enabled stakeholders to access live KPI data at any time
  * Removed dependency on manual reporting cycles

* **Time-based reporting**

  * Supported both weekly and monthly performance tracking

## Output & Usage

The system powers dashboards used for:

* Executive-level monitoring of business performance
* Real-time KPI tracking across multiple domains
* Identifying trends, risks, and operational gaps

Leadership can directly access and explore data, shifting reporting from a **push model (manual reports)** to a **self-service model (live dashboards)**.

### Dashboard Examples
![Dashboard Screenshot](images/kpi_overview.png)
![Dashboard Screenshot](images/funnel.png)

## Impact

* Reduced manual reporting effort by ~50% (15+ hours/week saved)
* Enabled real-time visibility for executive leadership
* Eliminated delays caused by scheduled reporting cycles
* Improved consistency and trust in KPI definitions
* Accelerated data-driven decision-making

## Key SQL Concepts

* Data aggregation and transformation
* Metric standardization and business logic design
* Time-based grouping and trend analysis
* Pipeline automation for recurring reporting


## Files

* `kpi_pipeline.sql` — SQL pipeline for KPI aggregation and reporting

## Notes

* Raw data are not included due to data confidentiality
* Metric definitions are simplified for demonstration purposes
