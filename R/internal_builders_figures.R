# .ggplot2_available <- function() {
#     requireNamespace("ggplot2", quietly = TRUE)
# }

# .build_figure_yield_distribution <- function(state) {
# if (!.ggplot2_available()) {
#     return(list(
#     items = list(yield_distribution_by_cultivar = NULL),
#     notes = "ggplot2 is not installed; yield distribution figure returned as NULL."
#     ))
# }

# plot_data <- data.frame(
#     cultivar = as.character(state$data[[state$columns$cultivar]]),
#     yield = state$data[[state$columns$yield]],
#     stringsAsFactors = FALSE
# )

# plot_object <- ggplot2::ggplot(plot_data, ggplot2::aes(x = cultivar, y = yield, colour = cultivar)) +
#     ggplot2::geom_boxplot(outlier.alpha = 0.4, show.legend = FALSE) +
#     ggplot2::labs(
#     title = "Yield distribution by cultivar",
#     x = "Cultivar",
#     y = "Yield"
#     ) +
#     ggplot2::theme_minimal()

# list(items = list(yield_distribution_by_cultivar = plot_object), notes = character())
# }

# .build_figure_yield_vs_risk_tradeoff <- function(state) {
# if (!.ggplot2_available()) {
#     return(list(
#     items = list(yield_vs_risk_tradeoff = NULL),
#     notes = "ggplot2 is not installed; yield versus risk figure returned as NULL."
#     ))
# }

# summary_table <- .get_cultivar_summary(state)
# risk_metric <- if (all(is.na(summary_table$frost_prob))) {
#     if (all(is.na(summary_table$heat_prob))) {
#     NULL
#     } else {
#     "heat_prob"
#     }
# } else {
#     "frost_prob"
# }

# if (is.null(risk_metric)) {
#     return(list(
#     items = list(yield_vs_risk_tradeoff = NULL),
#     notes = "No frost or heat risk column available; yield versus risk figure returned as NULL."
#     ))
# }

# plot_data <- summary_table
# plot_data$risk_probability <- plot_data[[risk_metric]]

# plot_object <- ggplot2::ggplot(
#     plot_data,
#     ggplot2::aes(x = yield_mean, y = risk_probability, colour = cultivar, label = cultivar)
# ) +
#     ggplot2::geom_point(size = 3, alpha = 0.8) +
#     ggplot2::labs(
#     title = "Yield versus risk trade-off",
#     x = "Mean yield",
#     y = risk_metric,
#     colour = "Cultivar"
#     ) +
#     ggplot2::theme_minimal()

# list(items = list(yield_vs_risk_tradeoff = plot_object), notes = character())
# }

# .build_figure_sowing_window_response <- function(state) {
# if (!.ggplot2_available()) {
#     return(list(
#     items = list(sowing_window_response = NULL),
#     notes = "ggplot2 is not installed; sowing window response figure returned as NULL."
#     ))
# }

# sowing_summary <- .get_sowing_summary(state)
# cultivar_summary <- .get_cultivar_summary(state)
# top_n <- min(state$options$top_n_figure, nrow(cultivar_summary))
# top_cultivars <- head(cultivar_summary$cultivar[order(-cultivar_summary$yield_mean)], top_n)
# plot_data <- sowing_summary[sowing_summary$cultivar %in% top_cultivars, , drop = FALSE]

# plot_object <- ggplot2::ggplot(
#     plot_data,
#     ggplot2::aes(x = sowing_date, y = mean_yield, group = cultivar, colour = cultivar)
# ) +
#     ggplot2::geom_line(linewidth = 0.8, alpha = 0.8) +
#     ggplot2::geom_point(size = 2) +
#     ggplot2::facet_wrap(stats::as.formula("~ cultivar"), scales = "free_y") +
#     ggplot2::labs(
#     title = "Sowing window response",
#     x = "Sowing date",
#     y = "Mean yield"
#     ) +
#     ggplot2::theme_minimal() +
#     ggplot2::theme(legend.position = "none")

# list(items = list(sowing_window_response = plot_object), notes = character())
# }

# # Registry pattern: figure builders are collected here in output order. Add a
# # new figure by writing a builder that returns list(items = list(name = plot_or_null),
# # notes = character()) and registering it here.
# .figure_registry <- list(
#     yield_distribution_by_cultivar = .build_figure_yield_distribution,
#     yield_vs_risk_tradeoff = .build_figure_yield_vs_risk_tradeoff,
#     sowing_window_response = .build_figure_sowing_window_response
# )