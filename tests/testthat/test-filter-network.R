test_that("filter_network args", {
  expect_error(
    filter_network(
      example_network,
      node_filters = list(bob = c("A", "C"), genetic_sex = "F"),
    )
  )
  expect_error(
    filter_network(
      example_network,
      node_filters = list(bob = c("A", "C"), genetic_sex = "F"),
    )
  )
  expect_error(
    filter_network(
      example_network,
      edge_column = "wij"
    )
  )
  expect_error(
    filter_network(
      example_network,
      node_filters = list(
        site = c("A", "D"),
        genetic_sex = NULL
      ),
    )
  )
})
test_that("filter_network values", {
  g <- filter_network(
    example_network,
    node_filters = list(site = "A", genetic_sex = "F")
  )
  expect_true("A" %in% igraph::V(g)$site)
  expect_false("B" %in% igraph::V(g)$site)
  expect_true("F" %in% igraph::V(g)$genetic_sex)
  expect_false("M" %in% igraph::V(g)$genetic_sex)

  g <- filter_network(
    example_network,
    node_filters = list(long = c(NA, 138.6))
  )
  r <- range(igraph::V(g)$long)
  expect_true(dplyr::between(138.59, r[1], r[2]))
  expect_false(dplyr::between(138.62, r[1], r[2]))
})

test_that("attr_in_cutoff args", {
  expect_error(attr_in_cutoff(1:10, c(1)))
})

test_that("attr_in_cutoff values", {
  expect_equal(
    attr_in_cutoff(1:10, c(1, 5)),
    rep(c(TRUE, FALSE), each = 5)
  )
  expect_equal(
    attr_in_cutoff(LETTERS[1:4], cutoff = c("A", "D")),
    c(TRUE, FALSE, FALSE, TRUE)
  )
})
