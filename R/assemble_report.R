
.registry_sections <- function() {
    list(
        summary = .section_summary_spec()
    )
}

.build_report_meta <- function(state, registry) {
    list(
        data = state$data,
        context = state$context,
        criteria = state$criteria,
        options = state$options,
        extras = state$extras,
        notes = state$notes,
        section_order = names(registry)
    )
}

.assemble_report <- function(state) {
    registry <- .registry_sections()
    sections <- lapply(
        registry,
        function(section_spec) section_spec$evaluate(state, section_spec)
    )

    report <- list(
        meta = .build_report_meta(state, registry),
        sections = sections
    )
    report[names(sections)] <- sections

    class(report) <- c("rapsimng_decide_report", class(report))
    report
}