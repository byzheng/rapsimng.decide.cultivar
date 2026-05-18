# .get_cultivar_summary <- function(state) {
#   .get_cached(state, "cultivar_summary", function() {
#     data <- state$data
#     columns <- state$columns
#     cultivars <- sort(unique(as.character(data[[columns$cultivar]])))
#     failure_threshold <- state$criteria$failure$yield_threshold

#     rows <- lapply(cultivars, function(cultivar_name) {
#       subset_rows <- data[[columns$cultivar]] == cultivar_name
#       subset_data <- data[subset_rows, , drop = FALSE]
#       yield_values <- subset_data[[columns$yield]]

#       frost_prob <- if (is.null(columns$frost)) {
#         NA_real_
#       } else {
#         .event_probability(subset_data[[columns$frost]])
#       }

#       heat_prob <- if (is.null(columns$heat)) {
#         NA_real_
#       } else {
#         .event_probability(subset_data[[columns$heat]])
#       }

#       data.frame(
#         cultivar = cultivar_name,
#         n_observations = sum(!is.na(yield_values)),
#         yield_mean = .safe_mean(yield_values),
#         yield_median = .safe_median(yield_values),
#         yield_q10 = .safe_quantile(yield_values, 0.1),
#         yield_q90 = .safe_quantile(yield_values, 0.9),
#         yield_sd = .safe_sd(yield_values),
#         yield_cv = .safe_cv(yield_values),
#         frost_prob = frost_prob,
#         heat_prob = heat_prob,
#         failure_prob = .failure_probability(yield_values, failure_threshold),
#         stringsAsFactors = FALSE
#       )
#     })

#     do.call(rbind, rows)
#   })
# }

# .get_sowing_summary <- function(state) {
#   .get_cached(state, "sowing_summary", function() {
#     data <- state$data
#     columns <- state$columns
#     grouping <- data.frame(
#       cultivar = as.character(data[[columns$cultivar]]),
#       sowing_value = data[[columns$sowing]],
#       stringsAsFactors = FALSE
#     )

#     keys <- interaction(grouping$cultivar, grouping$sowing_value, drop = TRUE, lex.order = TRUE)
#     split_data <- split(data, keys, drop = TRUE)

#     rows <- lapply(split_data, function(subset_data) {
#       data.frame(
#         cultivar = as.character(subset_data[[columns$cultivar]][1]),
#         sowing_date = subset_data[[columns$sowing]][1],
#         mean_yield = .safe_mean(subset_data[[columns$yield]]),
#         stringsAsFactors = FALSE
#       )
#     })

#     summary_table <- do.call(rbind, rows)
#     summary_table$cultivar <- as.character(summary_table$cultivar)
#     summary_table
#   })
# }

# .sowing_sensitivity_rows <- function(state) {
#   sowing_summary <- .get_sowing_summary(state)

#   split_rows <- split(sowing_summary, sowing_summary$cultivar, drop = TRUE)
#   lapply(names(split_rows), function(cultivar_name) {
#     subset_data <- split_rows[[cultivar_name]]
#     ordering <- .ordered_sowing_levels(subset_data$sowing_date)
#     order_index <- unname(ordering$map[as.character(subset_data$sowing_date)])
#     valid_pairs <- !is.na(order_index) & !is.na(subset_data$mean_yield)

#     slope <- NA_real_
#     if (sum(valid_pairs) >= 2L) {
#       slope <- unname(stats::coef(stats::lm(mean_yield ~ order_index,
#         data = data.frame(
#           mean_yield = subset_data$mean_yield[valid_pairs],
#           order_index = order_index[valid_pairs]
#         )
#       ))[2])
#     }

#     best_index <- if (all(is.na(subset_data$mean_yield))) {
#       NA_integer_
#     } else {
#       which.max(subset_data$mean_yield)
#     }

#     data.frame(
#       cultivar = cultivar_name,
#       n_sowing_dates = nrow(subset_data),
#       min_mean_yield = min(subset_data$mean_yield, na.rm = TRUE),
#       max_mean_yield = max(subset_data$mean_yield, na.rm = TRUE),
#       sensitivity_range = max(subset_data$mean_yield, na.rm = TRUE) - min(subset_data$mean_yield, na.rm = TRUE),
#       sensitivity_slope = slope,
#       best_sowing_date = if (is.na(best_index)) NA else as.character(subset_data$sowing_date[best_index]),
#       stringsAsFactors = FALSE
#     )
#   })
# }

# .get_sowing_sensitivity <- function(state) {
#   .get_cached(state, "sowing_sensitivity", function() {
#     rows <- .sowing_sensitivity_rows(state)
#     table <- do.call(rbind, rows)

#     invalid_rows <- !is.finite(table$min_mean_yield) | !is.finite(table$max_mean_yield)
#     table$min_mean_yield[invalid_rows] <- NA_real_
#     table$max_mean_yield[invalid_rows] <- NA_real_
#     table$sensitivity_range[invalid_rows] <- NA_real_
#     table
#   })
# }

# .evaluate_filter_rules <- function(summary_table, filter_criteria) {
#   if (is.null(filter_criteria) || length(filter_criteria) == 0) {
#     return(NULL)
#   }

#   metric_map <- c(
#     mean_yield_min = "yield_mean",
#     mean_yield_max = "yield_mean",
#     median_yield_min = "yield_median",
#     median_yield_max = "yield_median",
#     q10_min = "yield_q10",
#     q90_max = "yield_q90",
#     cv_max = "yield_cv",
#     frost_prob_max = "frost_prob",
#     heat_prob_max = "heat_prob",
#     failure_prob_max = "failure_prob"
#   )

#   pass_flags <- rep(TRUE, nrow(summary_table))
#   explain_rows <- list()

#   for (rule_name in names(filter_criteria)) {
#     if (!rule_name %in% names(metric_map)) {
#       next
#     }

#     threshold <- filter_criteria[[rule_name]]
#     metric_name <- unname(metric_map[[rule_name]])
#     metric_values <- summary_table[[metric_name]]

#     if (grepl("_min$", rule_name)) {
#       fails <- is.na(metric_values) | metric_values < threshold
#       comparator <- ">="
#     } else {
#       fails <- is.na(metric_values) | metric_values > threshold
#       comparator <- "<="
#     }

#     pass_flags <- pass_flags & !fails

#     if (any(fails)) {
#       explain_rows[[length(explain_rows) + 1L]] <- data.frame(
#         cultivar = summary_table$cultivar[fails],
#         rule = rule_name,
#         metric = metric_name,
#         comparator = comparator,
#         threshold = as.numeric(threshold),
#         observed = metric_values[fails],
#         reason = sprintf(
#           "%s %s %s failed",
#           metric_name,
#           comparator,
#           format(threshold, trim = TRUE)
#         ),
#         stringsAsFactors = FALSE
#       )
#     }
#   }

#   explain_table <- if (length(explain_rows) == 0) {
#     data.frame(
#       cultivar = character(),
#       rule = character(),
#       metric = character(),
#       comparator = character(),
#       threshold = numeric(),
#       observed = numeric(),
#       reason = character(),
#       stringsAsFactors = FALSE
#     )
#   } else {
#     do.call(rbind, explain_rows)
#   }

#   list(pass_flags = pass_flags, explain_table = explain_table)
# }

# .build_table_cultivar_summary <- function(state) {
#   list(items = list(cultivar_summary_table = .get_cultivar_summary(state)), notes = character())
# }

# .build_table_sowing_sensitivity <- function(state) {
#   list(items = list(sowing_sensitivity_table = .get_sowing_sensitivity(state)), notes = character())
# }

# .build_table_filters <- function(state) {
#   filter_results <- .evaluate_filter_rules(
#     summary_table = .get_cultivar_summary(state),
#     filter_criteria = state$criteria$filter
#   )

#   if (is.null(filter_results)) {
#     return(list(items = list(), notes = character()))
#   }

#   summary_table <- .get_cultivar_summary(state)
#   pass_table <- summary_table[filter_results$pass_flags, , drop = FALSE]
#   explain_table <- filter_results$explain_table

#   list(
#     items = list(
#       filter_pass_table = pass_table,
#       filter_explain_table = explain_table
#     ),
#     notes = character()
#   )
# }

# # Registry pattern: each builder returns list(items = list(name = value), notes = character()).
# # To add a new table, write one builder function following that contract and
# # register it here in the desired output order.
# .table_registry <- list(
#   cultivar_summary_table = .build_table_cultivar_summary,
#   sowing_sensitivity_table = .build_table_sowing_sensitivity,
#   filter_tables = .build_table_filters
# )