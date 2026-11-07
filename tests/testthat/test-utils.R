test_that("abbreviate works", {
  x <- c(
    "Jász-Nagykun-Szolnok",
    "Jono Tuke",
    "Bács-Kiskun",
    "Hajdú-Bihar",
    "Jono Tuke",
    "Adam Ben Rohrlach"
  )
  expect_equal(
    abbreviate_terms(x),
    c("JNS", "JT", "BK", "HB", "JT", "ABR")
  )
})
test_that("abbreviate works with brackets", {
  expect_equal(
    abbreviate_terms("A (N = 1)"),
    "A"
  )
})
test_that("add stars", {
  expect_equal(
    add_stars(c(0, 0.01, 0.05, 0.1, 0.5, 1)),
    c("***", "**", "*", ".", "", "")
  )
})
