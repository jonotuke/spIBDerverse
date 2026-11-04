#' Add clusters
#'
#' @param g igraph object
#' @param weight edge attribute to use for weighted clustering methods
#'
#' @returns adds clusters to igraph object
#'
#' @export
#' @examples
#' add_clustering(example_network)
add_clustering <- function(g, weight = "wij") {
  w <- igraph::edge_attr(g, weight)
  igraph::V(g)$.louvain <- stringr::str_c(
    "L",
    igraph::cluster_louvain(g) |>
      igraph::membership()
  )

  igraph::V(g)$.louvain_weighted <- stringr::str_c(
    "Lw",
    igraph::cluster_louvain(g, weights = w) |>
      igraph::membership()
  )
  igraph::V(g)$.eigen <- stringr::str_c(
    "E",
    igraph::cluster_leading_eigen(g) |> igraph::membership()
  )
  igraph::V(g)$.eigen_weighted <- stringr::str_c(
    "Ew",
    igraph::cluster_leading_eigen(g, weights = w) |> igraph::membership()
  )
  igraph::V(g)$.label_prop <- stringr::str_c(
    "LP",
    igraph::cluster_label_prop(g) |> igraph::membership()
  )
  igraph::V(g)$.label_prop_weighted <- stringr::str_c(
    "LPw",
    igraph::cluster_label_prop(g, weights = w) |> igraph::membership()
  )
  g
}

if (sys.nframe() == 5) {
  g <- add_clustering(example_network)
  g |> print()
  igraph::vertex_attr(g) |> print()
}
