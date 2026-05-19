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

.document_title <- function(meta) {
	title <- meta$extras$title

	if (is.null(title) || !nzchar(title)) {
		title <- meta$context$title
	}

	if (is.null(title) || !nzchar(title)) {
		title <- "Cultivar Suitability Report"
	}

	title
}

.document_object_lines <- function(name, value) {
	c(
		paste0(name, " <-"),
		utils::capture.output(dput(value))
	)
}

.document_prefix <- function(meta) {
	data_lines <- .document_object_lines("data", meta$data)
	context_lines <- .document_object_lines("context", meta$context)
	criteria_lines <- .document_object_lines("criteria", meta$criteria)
	options_lines <- .document_object_lines("options", meta$options)
	extras_lines <- .document_object_lines("extras", meta$extras)
	notes <- meta$notes

	if (length(notes) == 0) {
		notes <- "No evaluation notes were recorded."
	}

	list(
		name = "prefix",
		title = .document_title(meta),
		body = c(
			"---",
			paste0("title: \"", .document_title(meta), "\""),
			"format: html",
			"---",
			"",
			"```{r}",
			"#| label: setup-data",
			"#| include: false",
			data_lines,
			context_lines,
			criteria_lines,
			options_lines,
			extras_lines,
			"```",
			"",
			"## Evaluation Notes",
			"",
			paste0("- ", notes),
			""
		)
	)
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

	prefix <- .document_prefix(report$meta)

	documents <- lapply(section_order, function(section_name) {
			section_spec <- registry[[section_name]]
			section <- sections[[section_name]]

			if (is.null(section_spec) || is.null(section)) {
				return(NULL)
			}

			documented_section <- section_spec$document(section, report$meta)
			documented_section
		})

	document_lines <- unlist(
		c(
			list(prefix$body),
			lapply(documents, function(section) {
				if (is.null(section)) {
					return(NULL)
				}

				c(section$body, "")
			})
		),
		use.names = FALSE
	)

	structure(document_lines, class = c("rapsimng_decide_document", "character"))
}
