add_clustering <- function(g, weight = "wij") {
  w <- igraph::edge_attr(g, weight)
  V(g)$.louvain <- as.character(
    igraph::cluster_louvain(g) |>
      igraph::membership()
  )
  V(g)$.louvain_weighted <- as.character(
    igraph::cluster_louvain(g, weights = w) |>
      igraph::membership()
  )
  V(g)$.eigen <- as.character(
    igraph::cluster_leading_eigen(g) |> igraph::membership()
  )
  V(g)$.eigen_weighted <- as.character(
    igraph::cluster_leading_eigen(g, weights = w) |> igraph::membership()
  )
  V(g)$.label_prop <- as.character(
    igraph::cluster_label_prop(g) |> igraph::membership()
  )
  V(g)$.label_prop_weighted <- as.character(
    igraph::cluster_label_prop(g, weights = w) |> igraph::membership()
  )
  g
}

if (sys.nframe() == 5) {
  add_clustering(example_network) |> print()
}
