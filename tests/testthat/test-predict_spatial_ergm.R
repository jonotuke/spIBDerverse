test_that("args", {
  ergm <- fit_spatial_ergm(example_network, "lat", "long", "site")
  expect_error(
    predict_spatial_ergm(list(), N = 10)
  )
  expect_error(
    predict_spatial_ergm(ergm, N = "10")
  )
  expect_error(
    predict_spatial_ergm(ergm, N = 0, level = "bob")
  )
  expect_error(
    predict_spatial_ergm(list(), distance_term = 10)
  )
})

test_that("values", {
  ergm <- fit_spatial_ergm(example_network, "lat", "long", "site")$model[[2]]
  df <- ergm |> predict_spatial_ergm(N = 10)
  expect_equal(
    nrow(df),
    60
  )
  expect_equal(
    ncol(df),
    6
  )
  expect_equal(
    as.character(df[1, 1]),
    "C/C"
  )
})
