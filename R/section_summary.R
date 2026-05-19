.section_summary_spec <- function() {
	list(
		name = "summary",
		title = "Summary",
		description = "Summary section providing an overview of the evaluation context and key findings.",
		evaluate = .evaluate_section_summary,
		document = .document_section_summary
	)
}

.evaluate_section_summary <- function(state, spec = .section_summary_spec()) {
	list(
		name = spec$name,
		title = spec$title,
		description = spec$description
	)
}

.document_section_summary <- function(section, meta = NULL) {
	list(
		name = section$name,
		title = section$title,
		body = c(
			paste0("## ", section$title),
			"",
            "<!--",
            "Narrative:",
            "- Goal: summarise key decision-relevant findings across the report",
            "- Context: all structured outputs generated across sections (not narrative text)",
            "- Focus: cultivar ranking, yield-risk trade-offs, and major stress risks",
            "- Constraint: only use explicitly reported values or derived rankings from structured outputs",
            "- Avoid: using or summarising narrative text from previous sections",
            "- Output: a short, actionable summary for cultivar choice",
            "- Style: concise, farming decision oriented, decision-focused",
            "-->"
		)
	)
}