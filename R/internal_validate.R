.merge_lists <- function(defaults, overrides) {
    if (length(overrides) == 0) {
        return(defaults)
    }

    result <- defaults
    for (name in names(overrides)) {
        override_value <- overrides[[name]]
        default_value <- defaults[[name]]

        if (is.list(default_value) && is.list(override_value)) {
        result[[name]] <- .merge_lists(default_value, override_value)
        } else {
        result[[name]] <- override_value
        }
    }

    result
}

.standardise_context <- function(context) {
    defaults <- list(
        vars = list(
        cultivar_col = "cultivar",
        year_col = "year",
        sowing_col = "sowing_date",
        yield_col = "yield",
        frost_col = "frost_events",
        heat_col = "heat_events"
        )
    )

    .merge_lists(defaults, context)
}

.standardise_criteria <- function(criteria) {
    defaults <- list(
        failure = list(yield_threshold = NULL),
        filter = NULL
    )

    .merge_lists(defaults, criteria)
}

.standardise_options <- function(options) {
    defaults <- list(
        include_metrics = TRUE,
        include_tables = TRUE,
        include_figures = TRUE,
        top_n_figure = 6
    )

    standardised <- .merge_lists(defaults, options)
    standardised$top_n_figure <- as.integer(standardised$top_n_figure[[1]])

    if (is.na(standardised$top_n_figure) || standardised$top_n_figure < 1) {
        standardised$top_n_figure <- defaults$top_n_figure
    }

    standardised
}

.validate_inputs <- function(data, context, criteria, options) {
    if (!is.data.frame(data)) {
        stop("`data` must be a data.frame or tibble.", call. = FALSE)
    }

    if (nrow(data) == 0) {
        stop("`data` must contain at least one row.", call. = FALSE)
    }

    vars <- context$vars
    required_columns <- c(
        vars$cultivar_col,
        vars$year_col,
        vars$sowing_col,
        vars$yield_col
    )
    missing_columns <- setdiff(required_columns, names(data))

    if (length(missing_columns) > 0) {
        stop(
        sprintf(
            "Missing required columns: %s.",
            paste(missing_columns, collapse = ", ")
        ),
        call. = FALSE
        )
    }

    # yield_values <- data[[vars$yield_col]]
    # if (!is.numeric(yield_values)) {
    #     stop("The yield column must be numeric.", call. = FALSE)
    # }

    # optional_columns <- c(vars$frost_col, vars$heat_col)
    # for (column_name in optional_columns) {
    #     if (!column_name %in% names(data)) {
    #     next
    #     }

    #     if (!is.numeric(data[[column_name]]) && !is.logical(data[[column_name]])) {
    #     stop(
    #         sprintf("Optional risk column '%s' must be numeric or logical.", column_name),
    #         call. = FALSE
    #     )
    #     }
    # }

    # failure_threshold <- criteria$failure$yield_threshold
    # if (!is.null(failure_threshold)) {
    #     if (!is.numeric(failure_threshold) || length(failure_threshold) != 1L || is.na(failure_threshold)) {
    #     stop("`criteria$failure$yield_threshold` must be a single numeric value.", call. = FALSE)
    #     }
    # }

    # if (!is.null(criteria$filter) && !is.list(criteria$filter)) {
    #     stop("`criteria$filter` must be NULL or a named list.", call. = FALSE)
    # }

    # logical_options <- c("include_metrics", "include_tables", "include_figures")
    # for (option_name in logical_options) {
    #     option_value <- options[[option_name]]
    #     if (!is.logical(option_value) || length(option_value) != 1L || is.na(option_value)) {
    #     stop(sprintf("`options$%s` must be TRUE or FALSE.", option_name), call. = FALSE)
    #     }
    # }
}

.resolve_optional_column <- function(data, column_name) {
    if (is.null(column_name) || !nzchar(column_name) || !column_name %in% names(data)) {
        return(NULL)
    }

    column_name
}

.safe_mean <- function(x) {
    if (all(is.na(x))) {
        return(NA_real_)
    }

    mean(x, na.rm = TRUE)
}

.safe_median <- function(x) {
    if (all(is.na(x))) {
        return(NA_real_)
    }

    stats::median(x, na.rm = TRUE)
}

.safe_sd <- function(x) {
    x <- x[!is.na(x)]
    if (length(x) < 2L) {
        return(NA_real_)
    }

    stats::sd(x)
}

.safe_quantile <- function(x, prob) {
    if (all(is.na(x))) {
        return(NA_real_)
    }

    as.numeric(stats::quantile(x, probs = prob, na.rm = TRUE, names = FALSE, type = 7))
}

.safe_cv <- function(x) {
    mean_value <- .safe_mean(x)
    sd_value <- .safe_sd(x)

    if (is.na(mean_value) || is.na(sd_value) || isTRUE(all.equal(mean_value, 0))) {
        return(NA_real_)
    }

    sd_value / mean_value
}

.event_probability <- function(x) {
    observed <- x[!is.na(x)]
    if (length(observed) == 0L) {
        return(NA_real_)
    }

    mean(observed > 0)
}

.failure_probability <- function(yield_values, threshold) {
    if (is.null(threshold)) {
        return(NA_real_)
    }

    observed <- yield_values[!is.na(yield_values)]
    if (length(observed) == 0L) {
        return(NA_real_)
    }

    mean(observed < threshold)
}

.ordered_sowing_levels <- function(x) {
    observed <- x[!is.na(x)]
    if (length(observed) == 0L) {
        return(list(levels = character(), map = numeric()))
    }

    if (inherits(observed, "Date") || inherits(observed, "POSIXct") || is.numeric(observed)) {
        levels <- sort(unique(observed))
    } else {
        levels <- sort(unique(as.character(observed)))
    }

    map <- stats::setNames(seq_along(levels), as.character(levels))
    list(levels = levels, map = map)
}

.add_note <- function(notes, note) {
    unique(c(notes, note))
}