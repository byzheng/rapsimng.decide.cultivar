[![R-CMD-check.yaml](https://github.com/byzheng/rapsimng.decide.cultivar/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/byzheng/rapsimng.decide.cultivar/actions/workflows/R-CMD-check.yaml)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rapsimng.decide.cultivar)](https://cran.r-project.org/package=rapsimng.decide.cultivar)

[![](http://cranlogs.r-pkg.org/badges/grand-total/rapsimng.decide.cultivar?color=green)](https://cran.r-project.org/package=rapsimng.decide.cultivar)
[![](http://cranlogs.r-pkg.org/badges/last-month/rapsimng.decide.cultivar?color=green)](https://cran.r-project.org/package=rapsimng.decide.cultivar)
[![](http://cranlogs.r-pkg.org/badges/last-week/rapsimng.decide.cultivar?color=green)](https://cran.r-project.org/package=rapsimng.decide.cultivar)


# rapsimng.decide.cultivar

`rapsimng.decide.cultivar` analyses APSIM Next Generation simulation outputs to support cultivar selection decisions. It works on outputs already loaded into R and does not run APSIM simulations or make automatic recommendations.

## Installation

```r
remotes::install_github('byzheng/rapsimng.decide.cultivar')
```

## Usage

The two main functions are `evaluate()` and `document()`. Both accept a `data.frame` of APSIM outputs together with `context`, `criteria`, and `options` lists that control variable mapping and reporting behaviour.

`evaluate()` returns a structured report object. `document()` takes that object (or raw data) and assembles a formatted document.

The input data must contain columns for cultivar, year, sowing date, flowering date, yield, frost and heat reduction, and frost and heat event indicators. The exact column names are supplied through the `context$vars` list.

## Notes

The package is deterministic and reproducible. All decision criteria and risk thresholds are supplied explicitly by the caller and stored as metadata in the report.
