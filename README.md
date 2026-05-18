
# rapsimng.decide.cultivar

`rapsimng.decide.cultivar` provides functions to analyse APSIM Next Generation simulation outputs to support cultivar suitability assessment under defined environments and sowing conditions.

The package operates on APSIM outputs already loaded into R and focuses on transparent, reproducible evaluation of performance and risk. It does not run APSIM simulations, interpret user intent, or make automatic recommendations.


---

## Installation

Currently on [Github](https://github.com/byzheng/rapsimng.decide.cultivar) only. Install with:

```r
remotes::install_github('byzheng/rapsimng.decide.cultivar')
```

---

## Overview

Farmers and advisors often ask:

> *Which cultivar is suitable for my paddock under my sowing window?*

This package supports that question by analysing long-term APSIM simulations to describe:

- expected yield performance  
- variability across years  
- exposure to frost and heat risk  
- trade-offs between yield and risk  

Instead of returning a single “best” cultivar, the package provides a **decision landscape** that highlights strengths, weaknesses, and uncertainties for each option.

---

## Scope

- APSIM **Next Generation** outputs only  
- Input: a tidy `data.frame` of simulation results  
- Analysis at **cultivar × environment × sowing window** level  
- Deterministic, reproducible (no optimisation or AI)

---

## Not in Scope

- Running or modifying APSIM (`rapsimng`)
- Interpreting user intent (`agrillm`)
- Economic optimisation or automatic recommendation
- Black-box ranking or hidden decision rules

---

## Input Data

The package expects a `data.frame` (or `tibble`) where each row represents a simulation outcome for:

- cultivar  
- year  
- sowing date (or sowing window factor)  

Typical required variables:

- cultivar identifier  
- year  
- sowing date  
- yield  
- optional: phenology stages, frost/heat indicators  

The data can come from any source (e.g. `rapsimng`, database export, CSV), as long as structure is consistent.

---

## Decision Context

The package assumes a decision context such as:

- fixed location/environment (e.g. Wagga Wagga)  
- defined sowing window (e.g. 1–15 May)  
- a set of candidate cultivars  
- long-term climate variability (e.g. 30 years)  

---

## What the Package Provides

### 1. Yield Performance

- mean / median yield  
- lower quantile (poor-year performance)  
- interannual variability  

---

### 2. Risk Assessment (optional)

- frost exposure during sensitive stages  
- heat exposure  
- failure risk (probability below threshold yield)  

All risk definitions are explicit and stored as metadata.

---

### 3. Sowing Window Robustness

- performance across sowing dates within a window  
- sensitivity to sowing timing  

---

### 4. Trade-off Analysis

The package highlights trade-offs such as:

- high yield vs high risk  
- stable vs variable cultivars  
- timing-sensitive vs robust cultivars  

---

## Outputs

### Core Outputs

- cultivar performance summary  
- risk metrics per cultivar  
- assumption metadata  

---

### Decision-Support Outputs

- filtered candidates meeting criteria  
- explicit reasons for inclusion/exclusion  
- trade-off summaries  

Example:

> Cultivar A has high mean yield but exceeds frost-risk threshold in 30% of simulated years.  
> Cultivar B has lower yield but more stable performance and minimal frost exposure.

---

### Visual Outputs (optional)

- yield distributions by cultivar  
- yield vs risk trade-off plots  
- sowing window performance comparisons  

---

## Design Philosophy

This package follows three principles:

1. **Transparency**  
   All assumptions, thresholds, and metrics are explicit.

2. **Reproducibility**  
   Same input data always produces the same results.

3. **Separation of concerns**  
   - `rapsimng` → APSIM interaction  
   - `rapsimng.decide.*` → decision analysis  
   - `agrillm` → intent and explanation  

---

## Relationship to Other Packages

- **Depends conceptually on**: `rapsimng`  
- **Independent of**: APSIM runtime  
- **Callable by**: `agrillm`

---

## Key Insight

> This package does not select a cultivar.  
> It explains how cultivars perform and trade off under uncertainty.

---

## Status

Early-stage design focused on:
- cultivar suitability under phenology-driven environments  
- extensibility to other decision domains  

---