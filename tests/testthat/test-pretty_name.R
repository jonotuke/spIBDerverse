test_that("pretty_var_name", {
  expect_equal(
    pretty_var_name(
      c(".degree", NA, "bob", ".louvain")
    ),
    c("Degree", NA, "bob", "Louvain")
  )
})
test_that("pretty_choice", {
  expect_equal(
    names(pretty_choices(c(".degree", "bob", ".louvain"))),
    c("Degree", "bob", "Louvain")
  )
  expect_equal(
    as.character(pretty_choices(c(".degree", "bob", ".louvain"))),
    c(".degree", "bob", ".louvain")
  )
})
test_that("pretty_col", {
  df <- tibble::tibble(
    .degree = 1:5,
    bob = 1:5,
    .louvain = 1:5
  )
  expect_equal(
    colnames(pretty_col(df)),
    c("Degree", "bob", "Louvain")
  )
})
