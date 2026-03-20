# SMS Campaign

## Overview

Built a SQL pipeline to track user conversion from SMS campaigns to account signup and product registration. The pipeline attributes downstream user actions to SMS activity and enables measurement of campaign effectiveness.

## Dashboard
![Dashboard Screenshot](screenshots/sms_activities.png)

## Context

SMS campaigns were used to drive app engagement, but there was no clear way to measure:

* how many users signed up after receiving an SMS
* how many completed product registration
* how long it took users to convert

## Approach

* Cleaned and deduplicated raw SMS data at the user level

* Applied hashing to phone and email fields to handle PII safely

* Matched SMS recipients to user accounts using a **30-day attribution window**

* Joined with registration data to track full conversion flow:

  * SMS → Signup → Registration

* Built lifecycle flags:

  * signed up (yes/no)
  * registered (yes/no)

* Aggregated metrics at monthly and weekly levels:

  * total users reached
  * signup conversion rate
  * registration rate

* Calculated lead time from signup to registration using `DATE_DIFF`

## Output

Produced structured tables used for dashboard reporting, including:

* SMS-driven account creation trends
* conversion rates by time period
* registration rates following signup
* distribution of time to registration

## Key SQL Concepts

* Window functions for deduplication (`RANK`)
* Hashing for PII protection (`SHA256`)
* Attribution logic using date ranges
* Conditional aggregation (`COUNT DISTINCT IF`)
* Time-based aggregation (`DATE_TRUNC`)

## Files

* `sms_pipeline.sql` — SQL pipeline for SMS attribution and KPI calculation
