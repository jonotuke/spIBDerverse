good_node <- system.file(
  "extdata/load-default-data",
  "default-node.csv",
  package = "spIBDerverse"
)
good_edge <- system.file(
  "extdata/load-default-data",
  "default-edge.csv",
  package = "spIBDerverse"
)

test_that("load_default", {
  expect_error(load_default(
    node_file = "bob.csv"
  ))
  expect_error(load_default(
    node_file = good_node,
    edge_file = "inst/extdata/load-default-data/default-edges.bob"
  ))
})

test_that("filter_default_edges", {
  g <- load_default(good_node, good_edge)
  expect_error(
    filter_default_edges(list(), "site", edge_values = "A")
  )
  expect_equal(
    g,
    filter_default_edges(g)
  )
  expect_error(
    filter_default_edges(
      g,
      edge_attr = 2,
      edge_values = 2
    )
  )
  expect_error(
    filter_default_edges(
      g,
      edge_attr = "bob",
      edge_values = 2
    )
  )
})
