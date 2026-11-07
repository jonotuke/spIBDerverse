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
