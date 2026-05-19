
.section_summary_spec <- function() {
	list(
		name = "summary",
		title = "Summary",
		description = "Summary of the cultivar suitability evaluation, including key metrics, tables, and figures.",
		evaluate = .evaluate_section_summary,
		document = .document_section_summary
	)
}

.evaluate_section_summary <- function(state, spec = .section_summary_spec()) {
	list(
		name = spec$name,
		title = spec$title,
		description = spec$description,
		metrics = list(
			yield_summary = .build_metric_summary(state)
		)
	)
}

.compute_yield_summary <- function(state) {
    state$data |>
        dplyr::mutate(
            yield = .data[[state$columns$yield]] / 100
        ) |>
        dplyr::group_by(.data[[state$columns$cultivar]]) |>
        dplyr::summarise(
            yield_mean = mean(.data$yield, na.rm = TRUE),
            yield_sd = stats::sd(.data$yield, na.rm = TRUE),
			yield_cv = ifelse(.data$yield_mean != 0, .data$yield_sd / .data$yield_mean, NA_real_),
			yield_risk = sum(.data$yield < state$criteria$failure$yield_threshold, na.rm = TRUE) / sum(!is.na(.data$yield)),
            yield_q5 = stats::quantile(.data$yield, 0.05, na.rm = TRUE),
            yield_q10 = stats::quantile(.data$yield, 0.10, na.rm = TRUE),
			yield_q25 = stats::quantile(.data$yield, 0.25, na.rm = TRUE),
			yield_median = stats::median(.data$yield, na.rm = TRUE),
			yield_q75 = stats::quantile(.data$yield, 0.75, na.rm = TRUE),
			yield_q90 = stats::quantile(.data$yield, 0.90, na.rm = TRUE),
			yield_q95 = stats::quantile(.data$yield, 0.95, na.rm = TRUE),
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

.document_section_summary <- function(section, meta = NULL) {
	yield_summary <- .document_yield_summary(section$metrics$yield_summary)

	list(
		name = section$name,
		title = section$title,
		body = c(
			paste0("## ", section$title),
			"",
			section$description,
			"",
			paste0("### ", yield_summary$title),
			"",
			yield_summary$body
		)
	)
}


.document_yield_summary <- function(metrics) {
	summary_data_lines <- utils::capture.output(dput(metrics$value))

	table_columns <- c(
		"cultivar",
		"yield_mean",
		"yield_sd",
		"yield_cv",
		"yield_risk"
	)

	list(
		name = "yield_summary",
		title = "Yield Summary",
		body = c(
			"<!-- TEXT_yield_summary -->",
			"",
			"Summary statistics of yield performance across cultivars.",
			"",
			"```{r}",
			"yield_summary_data <-",
			summary_data_lines,
			"yield_summary_table <- yield_summary_data |>",
			"    dplyr::arrange(dplyr::desc(yield_mean)) |>",
			paste0(
				"    dplyr::select(",
				paste(table_columns, collapse = ", "),
				") |>",
				collapse = ""
			),
			"    dplyr::mutate(",
			"        dplyr::across(c(yield_mean, yield_sd, yield_cv, yield_risk), ~ round(.x, 2))",
			"    )",
			"knitr::kable(yield_summary_table)",
			"```",
			"",
			"Yield distribution across cultivars shown using quantile-based boxplots.",
			"",
			"```{r}",
			"yield_summary_plot_data <- yield_summary_data |>",
			"    dplyr::arrange(dplyr::desc(yield_mean)) |>",
			"    dplyr::mutate(cultivar = forcats::fct_reorder(cultivar, yield_mean, .desc = TRUE))",
			"ggplot2::ggplot(",
			"    yield_summary_plot_data,",
			"    ggplot2::aes(",
			"        x = cultivar,",
			"        ymin = yield_q5,",
			"        lower = yield_q25,",
			"        middle = yield_median,",
			"        upper = yield_q75,",
			"        ymax = yield_q95",
			"    )",
			") +",
			"    ggplot2::geom_boxplot(stat = \"identity\") +",
			"    ggplot2::coord_flip() +",
			"    ggplot2::labs(x = \"Yield (t/ha)\", y = \"Cultivar\")",
			"```"
		)
	)
}

