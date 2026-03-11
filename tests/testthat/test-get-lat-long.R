test_that("check get lat lon work", {
  expect_equal(
    get_lat_range(example_sf),
    c(-34.92707340, -34.80570040)
  )
  expect_equal(
    get_lat_range(example_sf, "lon"),
    c(138.5866551, 138.6253412)
  )
})
