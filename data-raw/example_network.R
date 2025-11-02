## code to prepare `example_network` dataset goes here
pacman::p_load(conflicted, tidyverse, ergm, igraph)
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

# Add lat and long
V(example_network)$lat <- case_when(
  V(example_network)$site == "A" ~ -34.91870870371196,
  V(example_network)$site == "B" ~ -34.922395551091626,
  V(example_network)$site == "C" ~ -34.809412383495506
)
V(example_network)$long <- case_when(
  V(example_network)$site == "A" ~ 138.60537266638642,
  V(example_network)$site == "B" ~ 138.59124348782686,
  V(example_network)$site == "C" ~ 138.62080456810344
)

err <- 0.005
V(example_network)$lat <- V(example_network)$lat +
  runif(vcount(example_network), min = -err, max = err)
V(example_network)$long <- V(example_network)$long +
  runif(vcount(example_network), min = -err, max = err)

# Clean up attributes
example_network <- delete_vertex_attr(example_network, "vertex.names")
example_network <- delete_vertex_attr(example_network, "na")
example_network <- delete_edge_attr(example_network, "na")
example_network
usethis::use_data(example_network, overwrite = TRUE)
