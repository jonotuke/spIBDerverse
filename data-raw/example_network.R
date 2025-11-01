## code to prepare `example_network` dataset goes here
pacman::p_load(conflicted, tidyverse, ergm)
# Simulate null network
basic_network <- network(40, directed = FALSE, density = 0)

# Add site and genetic sex
basic_network %v% "site" <- sample(LETTERS[1:3], size = 40, replace = TRUE)
basic_network %v% "genetic_sex" <- sample(
  c("M", "F"),
  size = 40,
  replace = TRUE
)

example_network <- simulate(
  basic_network ~ edges +
    nodematch("genetic_sex") +
    nodemix("site", levels2 = 0:6),
  coef = c(-4, 2, 1, 0, 2, 0, 0, 3)
)


# Convert to igraph
example_network <- intergraph::asIgraph(example_network)

# Add names
V(example_network)$name <- V(example_network)$vertex.names

# Add degree
V(example_network)$degree <- degree(example_network)

# Add wij
E(example_network)$wij <- runif(ecount(example_network), 0.1, 1)

# Clean up attributes
example_network <- delete_vertex_attr(example_network, "vertex.names")
example_network <- delete_edge_attr(example_network, "na")
example_network
usethis::use_data(example_network, overwrite = TRUE)
