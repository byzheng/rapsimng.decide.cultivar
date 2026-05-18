# .initialise_state <- function(data, context, criteria, options, extras = list()) {
#   vars <- context$vars
#   frost_column <- .resolve_optional_column(data, vars$frost_col)
#   heat_column <- .resolve_optional_column(data, vars$heat_col)

#   notes <- character()
#   if (is.null(frost_column)) {
#     notes <- .add_note(
#       notes,
#       sprintf(
#         "Optional frost column '%s' not found; frost metrics and tables are returned as NA.",
#         vars$frost_col
#       )
#     )
#   }
#   if (is.null(heat_column)) {
#     notes <- .add_note(
#       notes,
#       sprintf(
#         "Optional heat column '%s' not found; heat metrics and tables are returned as NA.",
#         vars$heat_col
#       )
#     )
#   }
#   if (is.null(criteria$failure$yield_threshold)) {
#     notes <- .add_note(
#       notes,
#       "No failure yield threshold provided; failure probabilities are returned as NA."
#     )
#   }

#   list(
#     data = data,
#     context = context,
#     criteria = criteria,
#     options = options,
#     extras = extras,
#     vars = vars,
#     columns = list(
#       cultivar = vars$cultivar_col,
#       year = vars$year_col,
#       sowing = vars$sowing_col,
#       yield = vars$yield_col,
#       frost = frost_column,
#       heat = heat_column
#     ),
#     notes = notes,
#     cache = new.env(parent = emptyenv())
#   )
# }

# .run_builders <- function(registry, state, section) {
#   include_flag <- state$options[[paste0("include_", section)]]
#   if (isFALSE(include_flag)) {
#     return(list(items = list(), notes = sprintf("%s output disabled by options.", section)))
#   }

#   items <- list()
#   notes <- character()

#   for (builder_name in names(registry)) {
#     result <- registry[[builder_name]](state)

#     if (!is.null(result$items) && length(result$items) > 0) {
#       items[names(result$items)] <- result$items
#     }
#     if (!is.null(result$notes) && length(result$notes) > 0) {
#       notes <- unique(c(notes, result$notes))
#     }
#   }

#   list(items = items, notes = notes)
# }

# .assemble_report <- function(state, metrics, tables, figures) {
#   report <- list(
#     meta = list(
#       generated_at = NULL,
#       input = list(
#         n_rows = nrow(state$data),
#         vars = state$vars,
#         criteria = state$criteria,
#         options = state$options,
#         extras = state$extras
#       ),
#       notes = unique(c(state$notes, metrics$notes, tables$notes, figures$notes))
#     ),
#     metrics = metrics$items,
#     tables = tables$items,
#     figures = figures$items
#   )

#   class(report) <- c("rapsimng_decide_report", class(report))
#   report
# }

# .get_cached <- function(state, key, compute) {
#   if (exists(key, envir = state$cache, inherits = FALSE)) {
#     return(get(key, envir = state$cache, inherits = FALSE))
#   }

#   value <- compute()
#   assign(key, value, envir = state$cache)
#   value
# }