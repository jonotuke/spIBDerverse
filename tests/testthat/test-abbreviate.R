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
