get_centrality_measures <- function(g) {
  igraph::as_data_frame(g, what = "vertices") |>
    as_tibble() |>
    dplyr::select(
      name,
      degree
    ) |>
    dplyr::mutate(
      closeness = igraph::closeness(g),
      betweenness = igraph::betweenness(g),
      eigen_centrality = igraph::eigen_centrality(g)$vector
    )
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_centrality_measures(example_network) |> print()
