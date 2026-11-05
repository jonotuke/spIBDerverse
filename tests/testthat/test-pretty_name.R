test_that("multiplication works", {
  expect_equal(
    pretty_var_name(
      c(".degree", NA, "bob", ".louvain")
    ),
    c("Degree", NA, "bob", "Louvain")
  )
})
