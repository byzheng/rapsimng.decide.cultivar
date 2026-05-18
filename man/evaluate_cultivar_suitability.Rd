% Generated manually to keep the package documented when roxygen cannot run.
\name{evaluate_cultivar_suitability}
\alias{evaluate_cultivar_suitability}
\title{Evaluate cultivar suitability from APSIM NG outputs}
\usage{
evaluate_cultivar_suitability(data, context = list(), criteria = list(), options = list(), ...)
}
\arguments{
  \item{data}{data.frame/tibble of APSIM outputs.}

  \item{context}{list controlling variable mapping and reporting context.}

  \item{criteria}{list controlling decision criteria, including optional risk and filtering thresholds.}

  \item{options}{list controlling output toggles and figure behaviour.}

  \item{...}{additional values stored in report metadata for downstream use.}
}
\value{Decision report object with \code{meta}, \code{metrics}, \code{tables}, and \code{figures} components.}
\description{
Analyse APSIM NG outputs already loaded into R to assess cultivar suitability under a defined environment and sowing window; returns a structured decision report.
}
\examples{
mock_data <- data.frame(
  cultivar = rep(c("Axe", "Beckom"), each = 6),
  year = rep(rep(2020:2022, each = 2), times = 2),
  sowing_date = rep(as.Date(c("2020-05-01", "2020-05-15")), times = 6),
  yield = c(4.1, 4.3, 3.8, 4.0, 4.5, 4.4, 4.0, 4.1, 3.7, 3.9, 4.2, 4.0),
  frost_events = c(0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0)
)

report <- evaluate_cultivar_suitability(
  mock_data,
  criteria = list(failure = list(yield_threshold = 3.9))
)

report$tables$cultivar_summary_table
}