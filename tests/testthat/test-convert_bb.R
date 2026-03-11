test_that("expand_line works", {
  expect_equal(
    expand_line(c(0, 1)),
    c(-0.1, 1.1)
  )
})
