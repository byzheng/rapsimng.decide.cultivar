test_that("required columns are validated", {
  invalid_data <- data.frame(
    cultivar = "Axe",
    year = 2020,
    sowing_date = as.Date("2020-05-01")
  )

  expect_error(
    evaluate_cultivar_suitability(invalid_data),
    "Missing required columns"
  )
})

test_that("report structure and class are returned", {
  mock_data <- data.frame(
    cultivar = rep(c("Axe", "Beckom"), each = 4),
    year = rep(rep(2020:2021, each = 2), times = 2),
    sowing_date = rep(as.Date(c("2020-05-01", "2020-05-15")), times = 4),
    yield = c(4.1, 4.3, 3.8, 4.0, 4.0, 4.1, 3.7, 3.9),
    stringsAsFactors = FALSE
  )

  report <- evaluate_cultivar_suitability(mock_data)

  expect_s3_class(report, "rapsimng_decide_report")
  expect_named(report, c("meta", "metrics", "tables", "figures"))
  expect_true(is.list(report$metrics))
  expect_true(is.data.frame(report$tables$cultivar_summary_table))
})

test_that("missing optional risk columns return NA and note metadata", {
  mock_data <- data.frame(
    cultivar = rep(c("Axe", "Beckom"), each = 4),
    year = rep(rep(2020:2021, each = 2), times = 2),
    sowing_date = rep(as.Date(c("2020-05-01", "2020-05-15")), times = 4),
    yield = c(4.1, 4.3, 3.8, 4.0, 4.0, 4.1, 3.7, 3.9),
    stringsAsFactors = FALSE
  )

  report <- evaluate_cultivar_suitability(mock_data)

  expect_true(is.na(report$metrics$frost_prob_overall))
  expect_true(is.na(report$metrics$heat_prob_overall))
  expect_true(any(grepl("Optional frost column", report$meta$notes, fixed = TRUE)))
  expect_true(any(grepl("Optional heat column", report$meta$notes, fixed = TRUE)))
})