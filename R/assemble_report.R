
.assemble_report <- function(state) {
    report <- list(
        summary = .registry_section_summary(state)   
    )

    class(report) <- c("rapsimng_decide_report", class(report))
    return(report)
}