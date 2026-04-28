# ACHP Medicare Advantage Competitive Analytics

## Overview

End-to-end Python analytics pipeline benchmarking 109K+ Medicare Advantage plan-county records across ACHP, National, and Regional cohorts — uncovering how National carriers responded to 2026 CMS reimbursement cuts by shifting hidden costs onto members while keeping premiums flat.

Built as part of an Analytics Consulting engagement at Johns Hopkins University Carey Business School for the Alliance of Community Health Plans (ACHP).

**Team:** Pranav Desurkar, Stephen Chang, Angela Kim, Shubham Joshi, Wanqian Xiong, Xier Shen

---

## Business Problem

**Situation:** CMS cut Medicare Advantage reimbursement rates for 2026. Every carrier had to respond.

**Complication:** Most National carriers kept premiums flat — then quietly hiked MOOP, raised Part D deductibles, and stripped drug benefits.

**Question:** When CMS cut payments, did carriers protect members or margins — and did ACHP plans do better?

---

## Key Findings

### Finding 1: National Carriers Shifted CMS Cuts to Members Through Hidden Cost Spikes

ACHP accepted higher premiums but kept MOOP increases significantly below National peers — absorbing CMS pressure through visible pricing instead of shifting hidden costs to members.

| Cohort | Δ Consolidated Premium | Δ MOOP |
|--------|----------------------|--------|
| ACHP-KP | +$10.90 | +$230.70 |
| ACHP-nonKP | +$5.70 | +$393.90 |
| National | +$3.00 | +$389.90 |
| Market Avg | +$3.80 | +$377.00 |

OLS regression with HC3 robust standard errors confirmed ACHP's pricing strategy is statistically distinct from National carriers (p<0.001).

### Finding 2: National Carriers Cut Drug Benefits to Finance Flat Premiums

81% of National plans eroded drug benefits vs. only 56% of ACHP plans. National avg Part D deductible increase: **+$118 vs. ACHP's +$25** — a $93 gap that is hidden behind flat premium headlines.

Aetna and Humana led in both deductible hikes (+$150 avg) and benefit erosion (80%+ erosion rate) — more than 6x ACHP's benchmark.

### Finding 3: ACHP Has a Structural Competitive Opening in HMO-POS Markets

National HMO-POS plans raised combined costs $199 more than ACHP — creating a direct member acquisition opportunity in the exact plan type where nationals are cutting most.

ACHP leads in **56% of the 875 counties** it competes in. Strongholds: upper Midwest and Pacific Northwest. Vulnerability zones: Virginia and New Mexico (nationals offering $0 premium).

---

## Analytical Approach

### Data Sources

- **CMS 2026 MA Landscape File** — premiums, MOOP, drug benefits, star ratings
- **CMS 2025 MA Landscape File** — same schema for YoY comparison
- **ACHP Member Crosswalk** — used to flag ACHP member plans within CMS data

### Key Metrics Analyzed

Part C Premium · Consolidated Premium · In-Network MOOP · Part D Deductible · Drug Benefit Type · Drug Benefit Erosion Flags · Plan Type · Enrollment · Star Rating

### Pipeline Architecture

```
CMS 2025 + 2026 Landscape Files
        ↓
4-Column Composite Key Merge
(Contract ID, Plan ID, State, County)
        ↓
Zero data loss validation — 109,015 matched rows
        ↓
Cohort Segmentation
(ACHP-KP | ACHP-nonKP | National | Regional)
        ↓
Enrollment-Weighted Aggregation
        ↓
Feature Engineering
(Drug erosion flags, cost shift metrics)
        ↓
Statistical Modeling
(OLS Regression, K-means Clustering, Logistic Regression)
        ↓
Geographic Scoring
(County-level competitive advantage map)
```

### Critical Data Fix: Deduplication Bug

The original pipeline used `drop_duplicates()` on Plan ID, discarding all county-level variation in premiums, MOOP, and enrollment. Any plan operating in multiple counties had only its first county row retained — making all downstream averages and regressions incorrect.

**Fix:** Year-over-year merge now uses a full 4-column key (Contract ID, Plan ID, State, County). No deduplication applied anywhere in the pipeline. Every plan-county row preserved — 109,015 matched rows across both years.

---

## Statistical Methods

### OLS Regression (HC3 Robust SE)

Two separate regressions with enrollment, star rating, and ACHP flag as predictors:

- **Outcome: Δ Consolidated Premium** — ACHP flag coefficient: **+$2.86*** (p<0.001)
- **Outcome: Δ MOOP** — ACHP flag coefficient: **+$161*** (p<0.001)

Results confirm ACHP's pricing strategy is statistically distinct even after controlling for enrollment and quality.

### K-means Clustering

Optimal k selected via elbow method, silhouette score, and Davies-Bouldin validation. PCA used for 2-component cluster visualization. Features: Premium, MOOP, Star Rating, Enrollment, Part D Deductible.

### Logistic Regression Churn Model

Plan exit risk modeled across 875 counties to identify geographic growth opportunities and structural vulnerability zones.

### Enrollment-Weighted Analysis

All cohort-level summaries use enrollment-weighted means via `weighted_mean()` with 2025 enrollment as weights — ensuring large plans don't count the same as small ones.

---

## Star Rating Comparison

| Cohort | Enrollment-Weighted Star Rating |
|--------|--------------------------------|
| Kaiser-only ACHP | 4.43 |
| All ACHP | 4.24 |
| Non-Kaiser ACHP | 4.04 |
| National Competitors | 3.89 |

ACHP maintains a 0.35-point quality advantage over National competitors — but Kaiser's higher quality comes with the highest cost increases (+$483 combined premium + MOOP).

---

## Recommendations

1. **Use data in congressional testimony** to push for back-end benefit disclosure requirements
2. **Equip member plans with competitive intelligence** against vulnerable National carriers in HMO-POS markets
3. **Publish findings to shift the public narrative** on Medicare Advantage plan quality

---

## Tech Stack

- **Python** — end-to-end pipeline
- **Pandas / NumPy** — data processing and aggregation
- **Statsmodels** — OLS regression with HC3 robust standard errors
- **Scikit-learn** — k-means clustering, PCA, logistic regression
- **Matplotlib / Seaborn** — visualization
- **Jupyter Notebook** — analysis and reporting

---

## Files

- `achp_pipeline.ipynb` — full analytics pipeline

---

## Notes

- Raw CMS data files not included due to file size; publicly available at cms.gov
- ACHP crosswalk not included due to confidentiality
- All analysis logic and methodology preserved

---

*Analytics Consulting Course — Johns Hopkins University Carey Business School, Spring 2026*
