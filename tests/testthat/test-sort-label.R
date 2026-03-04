test_that("sort-label works", {
  expect_equal(sort_label("A", "B"), "A==B")
  expect_equal(sort_label("B", "A"), "A==B")
  expect_equal(sort_label("A-B", "B-A"), "A-B==B-A")
})
