edge_file <- system.file(
  "extdata",
  "loader-data/loader-edges.tsv",
  package = "spIBDerverse"
)
node_file <- system.file(
  "extdata",
  "loader-data/loader-nodes.tsv",
  package = "spIBDerverse"
)
g <- loader(edge_file, node_file)
node_names <- igraph::vertex_attr_names(g)
test_that("loader args", {
  expect_error(loader("bob.xlsx"))
  expect_error(loader("bob.csv", "bob.xlsx"))
})

test_that("loader values", {
  expect_all_true(
    c(".degree", ".louvain", ".crawl") %in% node_names
  )
})
