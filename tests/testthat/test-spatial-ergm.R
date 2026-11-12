test_that("predict args", {
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

test_that("predict values", {
  ergm <- suppressMessages(
    fit_spatial_ergm(example_network, "lat", "long", "site")
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
    "B/C"
  )
})

test_that("get dist", {
  D <- get_dist(example_network, "lat", "long")
  expect_error(get_dist(example_network, "lat", "bob"))
  expect_error(get_dist(example_network, "bob", "long"))
  expect_equal(
    D[1, 2],
    D[2, 1]
  )
  expect_equal(D[1, 2], 13.06325, tolerance = 0.0001)
  expect_equal(D[1, 1], 0)
})
test_that("fit args", {
  expect_error(fit_spatial_ergm(list()))
  expect_error(
    fit_spatial_ergm(
      example_network,
      "bob",
      "long",
      "site"
    )
  )
  expect_error(
    fit_spatial_ergm(
      example_network,
      "lat",
      "bob",
      "site"
    )
  )
  expect_error(
    fit_spatial_ergm(
      example_network,
      "lat",
      "long",
      "bob"
    )
  )
})
