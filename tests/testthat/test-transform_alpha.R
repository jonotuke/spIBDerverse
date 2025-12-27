test_that("transform alpha", {
  expect_error(
    transform_alpha(c(0, 0)),
    "min is equal to max"
  )
  expect_error(
    transform_alpha(1:3, 1, 1),
    "a < b is not TRUE"
  )
  expect_error(
    transform_alpha(1:3, 1.1, 1),
    "a < b is not TRUE"
  )
  expect_equal(
    transform_alpha(1:3),
    c(0, 0.5, 1)
  )
  expect_equal(
    transform_alpha(1:3, a = 1, b = 2),
    c(1, 1.5, 2)
  )
})
