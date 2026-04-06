add_centrality_measures <- function(g) {
  igraph::V(g)$.degree <- igraph::degree(g)
  igraph::V(g)$.closeness = igraph::closeness(g)
  igraph::V(g)$.betweenness = igraph::betweenness(g)
  igraph::V(g)$.eigencentrality = igraph::eigen_centrality(g)$vector
  g
}
# add_centrality_measures(example_network)
