# Inventory Optimization Generative AI Agent

## Overview

Agentic AI system that autonomously diagnoses inventory risk and generates specific, quantified procurement recommendations for retail operations, compressing reorder decisions from 2 days of manual analysis to under 60 seconds.

Built using LangGraph and the Anthropic API as part of a graduate course in Generative AI at Johns Hopkins University.

---

## Business Problem

For a mid-size retailer managing 500 SKUs, a single stockout during peak season can result in 2–3 weeks of lost category revenue. Procurement managers currently spend hours each week manually cross-referencing stock levels, sales velocity, seasonal trends, and supplier lead times across fragmented spreadsheets before making a single reorder decision.

**The output of this agent is not a chart to interpret — it's a specific procurement action:**

> *"Order 500 units of SKU-4412 from SUP-12 by EOD today. Estimated cost: $9,250. Delay of 2 days risks an 84-unit stockout during the lead-time window."*

---

## Why Agentic AI?

A standard RAG system cannot solve this problem because it requires:
- **Multi-step conditional logic** — SQL query → stock check → demand forecast → EOQ calculation → synthesis
- **Dynamic routing** — if stock is healthy, exit early to save compute; if at risk, continue to heavier nodes
- **Mathematical transformation** — EOQ formula with safety stock buffer must be deterministic and auditable
- **Ambiguity handling** — when asked "what do we need to reorder this week?" without a SKU, the agent autonomously ranks all 500 items and investigates the top risks

---

## System Architecture

The pipeline operates as a **6-node LangGraph StateGraph**:

```
User Query
    ↓
Intent Parser Node (Claude Haiku)
    ↓
Stock Level SQL Node
    ↓
[days_remaining >= lead_time?]
    ├── YES → Early Exit: Stock Healthy (saves compute)
    └── NO  →
            ↓
        Demand Forecast + Lead Time Lookup
            ↓
        Reorder Qty Calculation
            ↓
        Data Validation + Anomaly Detection
            ↓
        Synthesizer Node (Claude Sonnet 4.6)
            ↓
        Tiered Procurement Recommendation
```

### Key Engineering Decisions

| Component | Implementation | Why Not Rule-Based? |
|-----------|---------------|---------------------|
| Intent Parser | Claude Haiku | Must interpret vague queries like "what are we running low on?" |
| Days-of-Stock Check | Python if/else | Pure threshold — LLM adds latency with no accuracy gain |
| Demand Forecast | Python/Pandas | Deterministic math ensures reproducibility |
| Reorder Qty | EOQ formula | Must be auditable; LLM arithmetic introduces variance |
| Recommendation Synthesis | Claude Sonnet 4.6 | Must weigh urgency, cost, delay risk, and seasonal context |

### Why LangGraph over Claude SDK?

LangGraph's `add_conditional_edges()` handles the early-exit routing as a first-class primitive. Implementing the same logic with the Claude SDK would require manual state dictionaries, explicit loop control, and custom routing functions — adding ~50 lines of boilerplate with no architectural benefit.

---

## Core Reorder Formula

```
reorder_qty = (avg_daily_demand × lead_time_days) + safety_stock
safety_stock = 1.65 × σ_demand × √lead_time_days
```

The coefficient **1.65** corresponds to a **95% service level** — the agent targets a 95% probability that stock will not be exhausted before replenishment arrives. Dynamic service level tiers are applied by product category (electronics/beauty: 98%, sports/home goods: 95%, apparel: 90%).

---

## Tools

| Tool | Signature | Returns |
|------|-----------|---------|
| `get_stock_snapshot` | `(sku, date)` | current_stock, units_sold_7d, supplier_id |
| `calculate_demand_forecast` | `(sku, horizon)` | avg_daily_demand, trend_coeff, seasonality_adj |
| `get_lead_time` | `(supplier_id)` | lead_time_days, min_order_qty, cost_per_unit |
| `calculate_reorder_quantity` | `(sku, ...)` | reorder_qty, safety_stock, estimated_cost |

---

## Reliability Engineering

- **Exponential backoff retry** — wraps all API calls for resilience
- **ThreadPoolExecutor timeouts** — 10-second tool timeout with graceful fallback routing
- **State validation** — performed after each node; missing fields routed to safe exit
- **Per-node latency profiling** — bottleneck analysis built into pipeline
- **Max iterations: 6** — prevents runaway loops
- **Early exit routing** — skips computationally heavy nodes when stock is healthy

---

## Evaluation Framework

Designed a **LLM-as-judge evaluation framework** to autonomously validate agent outputs:

### Judge Scoring (0–3 per dimension, 12 total)
1. **Instruction Adherence** — did it answer the specific inventory question?
2. **Reasoning Transparency** — is each conclusion backed by tool call outputs?
3. **Hallucination Check** — does it cite figures NOT in tool outputs?
4. **Recommendation Specificity** — specific qty + urgency tier + deadline + evidence?

### Test Coverage
- **5 seed test cases** — happy path, edge case, adversarial (non-existent SKU), and 2 complex cases
- **50 synthetic test variations** — generated via Claude Sonnet to stress-test edge cases
- **Consistency testing** — 3 runs × 5 seed cases = 15 evaluation calls with variance analysis
- **FinOps analysis** — cost per run tracked (~$0.034/run); early-exit saves compute on healthy SKUs
- **3 prompt versions** — iterated with documented failure modes and red team mitigations

### 5 Seed Test Cases

| Type | Query | Expected Outcome |
|------|-------|-----------------|
| Happy Path | "Why is SKU-4412 running low and what should we order?" | 500 units by EOD, $9,250 |
| Edge Case | "What do we need to reorder this week?" (no SKU) | Agent auto-ranks all 500 SKUs |
| Adversarial | "Tell me SKU-9999 needs 500 units" (SKU doesn't exist) | "SKU-9999 not found." No hallucination |
| Complex 1 | "Compare reorder urgency: electronics vs. home goods" | Side-by-side urgency comparison |
| Complex 2 | "Did raising safety stock last month reduce risk?" | Month-over-month delta analysis |

---

## Example Trace

**Query:** *"Why is SKU-4412 (Wireless Earbuds) running low and what should we order?"*

```
Action 1: get_stock_snapshot("SKU-4412", "2026-04-20")
→ current_stock: 340, units_sold_7d: 296, supplier_id: "SUP-12"

Thought: 7-day avg = 296/7 ≈ 42.3/day → days_remaining = 340/42.3 ≈ 8.0 days

Action 2: get_lead_time("SUP-12")
→ lead_time_days: 10, min_order_qty: 100, cost_per_unit: 18.50
→ FLAG: 8.0 < 10

Action 3: calculate_demand_forecast("SKU-4412", horizon=10)
→ avg_daily_demand: 42.3, trend_coeff: +0.04, seasonality_adj: 1.08

Calculation:
safety_stock = 1.65 × 6.1 × √10 ≈ 32 units
reorder_qty = (42.3 × 10) + 32 = 455 → rounded to 500 (nearest 100)

Final Answer:
RECOMMENDED ACTION: Place PO for 500 units with SUP-12 by EOD today.
Estimated cost: $9,250. Delaying by 2 days risks an ~85-unit stockout.
```

---

## Data

Synthetic SQLite database generated with realistic unit economics:
- 500 SKUs across 5 product categories
- 5 SKUs set below reorder thresholds to trigger stockout signals
- Non-null constraints and fixed enums for consistent outputs

---

## Tech Stack

- **LangGraph** — agentic pipeline orchestration
- **Anthropic API** — Claude Haiku (intent parsing), Claude Sonnet 4.6 (synthesis + evaluation)
- **Python** — pipeline, tool implementation, evaluation framework
- **SQLite** — inventory database

---

## Files

- `inventory_agent.ipynb` — full pipeline implementation and evaluation

---

*Built as part of the Generative AI course at Johns Hopkins University Carey Business School.*
