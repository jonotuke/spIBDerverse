test_that("add alpha works", {
  expect_error(add_alpha(example_network, "bob"))
  g1 <- add_alpha(example_network)
  expect_true(
    all(igraph::V(g1)$.alpha == 1)
  )
  g2 <- add_alpha(example_network, "degree")
  expect_equal(
    igraph::V(g2)$.alpha,
    as.numeric(igraph::degree(g2))
  )
  g3 <- add_alpha(example_network, "betweenness")
  expect_equal(
    igraph::V(g3)$.alpha,
    as.numeric(igraph::betweenness(example_network))
  )
})
