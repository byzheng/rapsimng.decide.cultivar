# .build_metric_counts <- function(state) {
#   data <- state$data
#   columns <- state$columns

#   list(
#     items = list(
#       n_cultivars = length(unique(as.character(data[[columns$cultivar]]))),
#       n_years = length(unique(data[[columns$year]])),
#       n_sowing_dates = length(unique(as.character(data[[columns$sowing]])))
#     ),
#     notes = character()
#   )
# }

# .build_metric_yield_mean_overall <- function(state) {
#   list(
#     items = list(
#       yield_mean_overall = .safe_mean(state$data[[state$columns$yield]])
#     ),
#     notes = character()
#   )
# }

# .build_metric_yield_cv_summary <- function(state) {
#   summary_table <- .get_cultivar_summary(state)

#   list(
#     items = list(
#       yield_cv_by_cultivar_summary = .safe_median(summary_table$yield_cv)
#     ),
#     notes = character()
#   )
# }

# .build_metric_frost_prob_overall <- function(state) {
#   value <- if (is.null(state$columns$frost)) {
#     NA_real_
#   } else {
#     .event_probability(state$data[[state$columns$frost]])
#   }

#   list(items = list(frost_prob_overall = value), notes = character())
# }

# .build_metric_heat_prob_overall <- function(state) {
#   value <- if (is.null(state$columns$heat)) {
#     NA_real_
#   } else {
#     .event_probability(state$data[[state$columns$heat]])
#   }

#   list(items = list(heat_prob_overall = value), notes = character())
# }

# .build_metric_failure_prob_overall <- function(state) {
#   value <- .failure_probability(
#     yield_values = state$data[[state$columns$yield]],
#     threshold = state$criteria$failure$yield_threshold
#   )

#   list(items = list(failure_prob_overall = value), notes = character())
# }

# # Registry pattern: metrics are ordered here. To add a metric, implement a new
# # builder that returns list(items = list(metric_name = value), notes = character())
# # and register it below.
# .metric_registry <- list(
#   counts = .build_metric_counts,
#   yield_mean_overall = .build_metric_yield_mean_overall,
#   yield_cv_by_cultivar_summary = .build_metric_yield_cv_summary,
#   frost_prob_overall = .build_metric_frost_prob_overall,
#   heat_prob_overall = .build_metric_heat_prob_overall,
#   failure_prob_overall = .build_metric_failure_prob_overall
# )