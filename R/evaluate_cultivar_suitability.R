#' Evaluate cultivar suitability from APSIM NG outputs
#'
#' @description
#' Analyse APSIM NG outputs already loaded into R to assess cultivar suitability
#' under a defined environment and sowing window; returns a structured decision
#' report.
#'
#' @param data data.frame/tibble of APSIM outputs.
#' @param context list controlling variable mapping and reporting context.
#' @param criteria list controlling decision criteria, including optional risk and
#'   filtering thresholds.
#' @param options list controlling output toggles and figure behaviour.
#' @param ... additional values stored in report metadata for downstream use.
#'
#' @return Decision report object with `meta`, `metrics`, `tables`, and
#'   `figures` components.
#'
#' @examples
#' mock_data <- data.frame(
#'   cultivar = rep(c("Axe", "Beckom"), each = 6),
#'   year = rep(rep(2020:2022, each = 2), times = 2),
#'   sowing_date = rep(as.Date(c("2020-05-01", "2020-05-15")), times = 6),
#'   yield = c(4.1, 4.3, 3.8, 4.0, 4.5, 4.4, 4.0, 4.1, 3.7, 3.9, 4.2, 4.0),
#'   frost_events = c(0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0)
#' )
#'
#' report <- evaluate_cultivar_suitability(
#'   mock_data,
#'   criteria = list(failure = list(yield_threshold = 3.9))
#' )
#'
#' report$tables$cultivar_summary_table
#' @export
evaluate_cultivar_suitability <- function(
	data,
	context = list(),
	criteria = list(),
	options = list(),
	...
) {

	# context <- .standardise_context(context)
	# criteria <- .standardise_criteria(criteria)
	# options <- .standardise_options(options)

	.validate_inputs(
		data = data,
		context = context,
		criteria = criteria,
		options = options
	)

	state <- .initialise_state(
		data = data,
		context = context,
		criteria = criteria,
		options = options
	)
	.assemble_report(state)
}
