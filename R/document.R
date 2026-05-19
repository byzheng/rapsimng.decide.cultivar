#' Document cultivar suitability from APSIM NG outputs
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
#' @export
document <- function(
	data,
	context = list(),
	criteria = list(),
	options = list(),
	...
) {
	report <- if (inherits(data, "rapsimng_decide_report")) {
		data
	} else {
		evaluate(
			data = data,
			context = context,
			criteria = criteria,
			options = options,
			...
		)
	}

	.assemble_document(report)
}

.assemble_document <- function(report) {
	registry <- .registry_sections()
	sections <- report$sections

	if (is.null(sections)) {
		sections <- report[setdiff(names(report), "meta")]
	}

	section_order <- report$meta$section_order
	if (is.null(section_order)) {
		section_order <- names(sections)
	}

	document_lines <- unlist(
		lapply(section_order, function(section_name) {
			section_spec <- registry[[section_name]]
			section <- sections[[section_name]]

			if (is.null(section_spec) || is.null(section)) {
				return(NULL)
			}

			documented_section <- section_spec$document(section, report$meta)
			c(documented_section$body, "")
		}),
		use.names = FALSE
	)

	structure(document_lines, class = c("rapsimng_decide_document", "character"))
}
