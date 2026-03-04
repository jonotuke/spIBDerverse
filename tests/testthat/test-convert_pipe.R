test_that("multiplication works", {
  expect_equal(
    convert_pipe("jono, ben"),
    "jono|ben"
  )
})
