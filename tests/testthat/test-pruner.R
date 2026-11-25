test_that("classify_edges args", {
  expect_error(
    classify_edges(example_network)
  )
  expect_error(
    classify_edges(
      example_network,
      filters = list(
        wij = c(NA, 10),
        wij = c(NA, 10)
      )
    )
  )
  expect_error(
    classify_edges(
      example_network,
      filters = list(
        site = "A"
      )
    )
  )
})

test_that("classify_edges values", {
  g <- classify_edges(
    example_network,
    filters = list(
      edge_type = c("A", "B"),
      wij = c(0.5, NA)
    )
  )
  expect_contains(igraph::edge_attr_names(g), ".edgetype")
  expect_equal(
    igraph::edge_attr(g, ".edgetype"),
    # fmt: skip
    c("good", "bad", "good", "bad", "bad", "bad", "bad", "bad", "bad", 
      "bad", "bad", "bad", "bad", "good", "bad", "bad", "bad", "bad", 
      "good", "bad", "bad", "good", "good", "bad", "bad", "bad", "bad", 
      "bad", "bad", "bad", "bad", "bad", "bad", "bad", "bad", "good", 
      "bad", "good", "good", "bad", "bad", "bad", "bad", "bad", "good", 
      "bad", "bad", "bad", "bad", "bad", "good", "bad", "bad", "bad", 
      "good", "good", "bad", "bad", "bad", "bad", "good", "bad", "bad", 
      "good", "bad", "bad", "bad", "bad", "bad", "bad", "bad", "bad", 
      "bad", "good", "bad", "bad", "bad", "bad", "good", "bad", "bad", 
      "good", "good", "bad", "bad", "bad", "bad", "bad", "bad", "good", 
      "bad", "good", "bad", "bad", "good", "bad", "bad", "good", "good", 
      "bad", "bad", "bad")
  )
})

test_that("remove_bad_edges args", {
  expect_error(remove_bad_edges(example_network))
  g <- example_network
  igraph::E(g)$.edgetype <- "good"
  expect_message(remove_bad_edges(g))
})

test_that("remove_bad_edges values", {
  g <- example_network
  igraph::E(g)$.edgetype <- rep(c("bad", "good"), each = 51)
  g <- remove_bad_edges(g)
  expect_equal(igraph::vcount(g), 26)
  expect_equal(igraph::ecount(g), 46)
})

test_that("classify_nodes args", {
  expect_error(classify_nodes(example_network))
  expect_error(classify_nodes(
    example_network,
    filters = list(site = "A", site = "B")
  ))
  expect_error(classify_nodes(
    example_network,
    filters = list(bob = "A")
  ))
})

test_that("classify_nodes values", {
  g <- classify_nodes(example_network, filters = list(site = "A"))
  expect_contains(igraph::vertex_attr_names(g), ".nodetype")
  expect_equal(
    g |> igraph::vertex_attr(".nodetype"),
    # fmt: skip
    c("good", "good", "good", "bad", "good", "bad", "bad", "good", 
      "bad", "bad", "bad", "bad", "bad", "good", "bad", "good", "bad", 
      "bad", "bad", "bad", "bad", "good", "good", "good", "bad", "bad", 
      "bad", "bad", "good", "bad", "bad", "good", "good", "good", "good", 
      "good", "good", "good", "bad", "good")
  )
})

test_that("pruner values", {
  g <- pruner(
    example_network,
    node_filters = list(site = c("A", "B")),
    edge_filters = list(edge_type = c("A", "B"))
  )
  expect_equal(igraph::vcount(g), 21)
  expect_equal(igraph::ecount(g), 24)
  expect_in(igraph::V(g)$site, c("A", "B"))
  expect_in(igraph::E(g)$.edgetype, c("good"))
})
