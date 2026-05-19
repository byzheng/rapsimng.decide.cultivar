.initialise_state <- function(data, context, criteria, options, extras = list()) {
  vars <- context$vars
  # frost_column <- .resolve_optional_column(data, vars$frost_col)
  # heat_column <- .resolve_optional_column(data, vars$heat_col)

  notes <- character()
  # if (is.null(frost_column)) {
  #   notes <- .add_note(
  #     notes,
  #     sprintf(
  #       "Optional frost column '%s' not found; frost metrics and tables are returned as NA.",
  #       vars$frost_col
  #     )
  #   )
  # }
  # if (is.null(heat_column)) {
  #   notes <- .add_note(
  #     notes,
  #     sprintf(
  #       "Optional heat column '%s' not found; heat metrics and tables are returned as NA.",
  #       vars$heat_col
  #     )
  #   )
  # }
  # if (is.null(criteria$failure$yield_threshold)) {
  #   notes <- .add_note(
  #     notes,
  #     "No failure yield threshold provided; failure probabilities are returned as NA."
  #   )
  # }

  list(
    data = data,
    context = context,
    criteria = criteria,
    options = options,
    extras = extras,
    vars = vars,
    columns = list(
      cultivar = vars$cultivar_col,
      year = vars$year_col,
      sowing = vars$sowing_col,
      yield = vars$yield_col,
      frost = NULL,
      heat = NULL
    ),
    notes = notes,
    cache = new.env(parent = emptyenv())
  )
}
