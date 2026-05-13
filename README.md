# rapsimng.decide.cultivar

`rapsimng.decide.cultivar` is an R package for analysing APSIM Next Generation
simulation outputs to support cultivar comparison and selection for specific
environments, managements, and decision criteria.

The package does not run APSIM, interpret user intent, or recommend “optimal”
choices. Instead, it provides structured, assumption-explicit summaries of model
outputs (e.g. yield, phenology timing, stress exposure, stability metrics) that
can be used consistently across experimental analysis, decision-support
workflows, and AI-mediated interfaces such as `agrillm`.



## Scope

- APSIM **Next Generation only**
- Cultivar-level comparison based on simulated outputs
- Deterministic, reproducible analysis


## Installation

Currently on [Github](https://github.com/byzheng/rapsimng.decide.cultivar) only. Install with:

```r
remotes::install_github('byzheng/rapsimng.decide.cultivar')
```
