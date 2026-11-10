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
test_that("pipe", {
  expect_equal(
    convert_pipe("jono, ben"),
    "jono|ben"
  )
})
test_that("sort-label works", {
  expect_equal(sort_label("A", "B"), "A==B")
  expect_equal(sort_label("B", "A"), "A==B")
  expect_equal(sort_label("A-B", "B-A"), "A-B==B-A")
})
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
test_that("Get errors", {
  expect_error(
    check_node_attributes(example_network, "bob")
  )
  expect_null(
    check_node_attributes(example_network, "site")
  )
})

test_that("get_ergm_preds args", {
  expect_error(get_ergm_preds(list()))
})

test_that("get_ergm_preds values", {
  ergms <- fit_ergms(
    example_network,
    c("site", "lat"),
    c("nodemix", "nodecov")
  ) |>
    suppressWarnings()
  expect_equal(
    get_ergm_preds_df(ergms[[3]])$pred,
    c(NA, "site", "lat")
  )
  expect_equal(
    get_ergm_preds_df(ergms[[3]])$type,
    c("network", "categorical", "numeric")
  )
})
