test_that("args", {
  ergm <- suppressMessages(
    fit_spatial_ergm(example_network, "lat", "long", "site")
  )
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
  ergm <- suppressMessages(
    fit_spatial_ergm(example_network, "lat", "long", "site")$model[[2]]
  )
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
test_that("get_dist", {
  D <- get_dist(example_network, "lat", "long")
  expect_error(get_dist(example_network, "lat", "bob"))
  expect_error(get_dist(example_network, "bob", "long"))
  expect_equal(
    D[1, 2],
    D[2, 1]
  )
  expect_equal(D[1, 2], 0.3041107, tolerance = 0.0001)
  expect_equal(D[1, 1], 0)
})
