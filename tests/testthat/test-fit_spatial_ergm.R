test_that("spatial ergm args", {
  expect_error(
    fit_spatial_ergm(list())
  )
  expect_error(
    fit_spatial_ergm(example_network, "bob", "long")
  )
  expect_error(
    fit_spatial_ergm(example_network, "lat", "bob")
  )
  expect_error(
    fit_spatial_ergm(example_network, "lat", "long", "bob")
  )
  expect_equal(
    fit_spatial_ergm(example_network, "lat", "long", "site") |>
      broom::tidy() |>
      dplyr::pull(estimate),
    c(-2.32, -0.0120, 0.806, 1.63, 2.42),
    tolerance = 0.01
  )
})
