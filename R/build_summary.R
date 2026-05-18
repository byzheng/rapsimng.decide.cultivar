
.registry_section_summary <- function(state) {
	list(
		name = "summary",
		title = "Summary",
		description = "Summary of the cultivar suitability evaluation, including key metrics, tables, and figures.",
		metrics = .build_metric_summary(state)
	)
}

.compute_yield_summary <- function(state) {
    state$data |>
        dplyr::mutate(
            yield = .data[[state$columns$yield]] / 100
        ) |>
        dplyr::group_by(.data[[state$columns$cultivar]]) |>
        dplyr::summarise(
            yield_mean = mean(yield, na.rm = TRUE),
            yield_sd = sd(yield, na.rm = TRUE),
			yield_cv = ifelse(yield_mean != 0, yield_sd / yield_mean, NA_real_),
			yield_risk = sum(yield < state$criteria$failure$yield_threshold, na.rm = TRUE) / sum(!is.na(yield)),
            yield_q5 = quantile(yield, 0.05, na.rm = TRUE),
            yield_q10 = quantile(yield, 0.10, na.rm = TRUE),
			yield_q25 = quantile(yield, 0.25, na.rm = TRUE),
			yield_median = median(yield, na.rm = TRUE),
			yield_q75 = quantile(yield, 0.75, na.rm = TRUE),
			yield_q90 = quantile(yield, 0.90, na.rm = TRUE),
			yield_q95 = quantile(yield, 0.95, na.rm = TRUE),
            .groups = "drop"
        )
}


.build_metric_summary <- function(state) {

    values <- .compute_yield_summary(state)

    metric_def <- tibble::tibble(
        name = c("yield_mean", "yield_sd", "yield_cv", "yield_risk", "yield_q5", "yield_q10", "yield_q25", "yield_median", "yield_q75", "yield_q90", "yield_q95"),
        title = c("Average Yield", "Yield Standard Deviation", "Yield Coefficient of Variation", "Yield Risk", "5th Percentile Yield", "10th Percentile Yield", "25th Percentile Yield", "Median Yield", "75th Percentile Yield", "90th Percentile Yield", "95th Percentile Yield"),
		description = c(
			"The average yield across all years for each cultivar.",
			"The standard deviation of yield across all years for each cultivar.",
			"The coefficient of variation of yield across all years for each cultivar, calculated as the standard deviation divided by the mean.",
			paste0("The proportion of years where the yield was below the failure threshold (", state$criteria$failure$yield_threshold, " t/ha), indicating the risk of poor performance."),
			"The 5th percentile of yield across all years for each cultivar, representing a low yield scenario.",
			"The 10th percentile of yield across all years for each cultivar, representing a very low yield scenario.",
			"The 25th percentile of yield across all years for each cultivar, representing a below-average yield scenario.",
			"The median yield across all years for each cultivar, representing a typical yield scenario.",
			"The 75th percentile of yield across all years for each cultivar, representing an above-average yield scenario.",
			"The 90th percentile of yield across all years for each cultivar, representing a high yield scenario.",
			"The 95th percentile of yield across all years for each cultivar, representing a very high yield scenario."
		),
        unit = c("t/ha", "t/ha", "t/ha",  "", "t/ha", "t/ha", "t/ha", "t/ha", "t/ha", "t/ha", "t/ha")
    )

    list(
        name = "yield_summary",
        value = values,
        metric_def = metric_def,
        description = "The summary statistics of yield across all cultivars and years impacted by frost and heat stresses."
    )
}
