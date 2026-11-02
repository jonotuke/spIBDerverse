make_test_graph <- function() {
  g <- igraph::make_graph(~ A - B, B - C, C - D)
  g <- igraph::set_vertex_attr(g, "site", value = c("north", NA, "south", NA))
  g <- igraph::set_vertex_attr(g, "genetic_sex", value = c(NA, "M", "F", "F"))
  g <- igraph::set_vertex_attr(g, "complete", value = c("x", "y", "z", "w"))
  g
}

test_that("NAs in the named attribute become 'unknown'", {
  g <- convert_na_unknown(make_test_graph(), "site")

  expect_equal(
    igraph::vertex_attr(g, "site"),
    c("north", "Unknown", "south", "Unknown")
  )
})

test_that("non-NA values in the named attribute are left unchanged", {
  g <- convert_na_unknown(make_test_graph(), "site")
  site <- igraph::vertex_attr(g, "site")

  expect_equal(site[c(1, 3)], c("north", "south"))
})

test_that("other attributes are not touched", {
  g <- convert_na_unknown(make_test_graph(), "site")

  expect_equal(igraph::vertex_attr(g, "genetic_sex"), c(NA, "M", "F", "F"))
  expect_equal(igraph::vertex_attr(g, "complete"), c("x", "y", "z", "w"))
})

test_that("an attribute with no NAs is returned unchanged", {
  g_in <- make_test_graph()
  g_out <- convert_na_unknown(g_in, "complete")

  expect_identical(
    igraph::vertex_attr(g_out, "complete"),
    igraph::vertex_attr(g_in, "complete")
  )
})

test_that("a missing attribute name gives an informative error", {
  expect_error(
    convert_na_unknown(make_test_graph(), "not_here"),
    "not_here is not a node attribute",
    fixed = TRUE
  )
})

test_that("an edge attribute name is not accepted as a node attribute", {
  g <- igraph::set_edge_attr(make_test_graph(), "weight", value = c(1, NA, 3))

  expect_error(
    convert_na_unknown(g, "weight"),
    "weight is not a node attribute",
    fixed = TRUE
  )
})

test_that("a graph with no node attributes errors", {
  expect_error(
    convert_na_unknown(igraph::make_ring(3), "site"),
    "site is not a node attribute",
    fixed = TRUE
  )
})


test_that("NAs in every node attribute become 'unknown'", {
  g <- convert_nas_unknown(make_test_graph())

  expect_equal(
    igraph::vertex_attr(g, "site"),
    c("north", "Unknown", "south", "Unknown")
  )
  expect_equal(
    igraph::vertex_attr(g, "genetic_sex"),
    c("Unknown", "M", "F", "F")
  )
  expect_equal(igraph::vertex_attr(g, "complete"), c("x", "y", "z", "w"))
})

test_that("no NAs remain in any node attribute", {
  g <- convert_nas_unknown(make_test_graph())

  for (attr in igraph::vertex_attr_names(g)) {
    expect_false(anyNA(igraph::vertex_attr(g, attr)), label = attr)
  }
})

test_that("edge attributes are left alone", {
  g <- igraph::set_edge_attr(make_test_graph(), "weight", value = c(1, NA, 3))

  g <- convert_nas_unknown(g)

  expect_equal(igraph::edge_attr(g, "weight"), c(1, NA, 3))
})
