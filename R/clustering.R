#' Add clusters
#'
#' Nodes with no connections to other nodes (isolates) are assigned to a
#' single cluster called "disconnected" for every clustering method, instead
#' of each being placed in its own singleton cluster.
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

  disconnected <- igraph::degree(g, loops = FALSE) == 0

  label_clusters <- function(prefix, communities) {
    m <- as.integer(igraph::membership(communities))
    out <- rep("disconnected", length(m))
    # Renumber connected clusters 1, 2, 3, ... with no gaps,
    # keeping the algorithm's original ordering
    m_conn <- m[!disconnected]
    out[!disconnected] <- stringr::str_c(
      prefix,
      match(m_conn, sort(unique(m_conn)))
    )
    out
  }

  igraph::V(g)$.louvain <- label_clusters(
    "L",
    igraph::cluster_louvain(g)
  )
  igraph::V(g)$.louvain_weighted <- label_clusters(
    "Lw",
    igraph::cluster_louvain(g, weights = w)
  )
  igraph::V(g)$.eigen <- label_clusters(
    "E",
    igraph::cluster_leading_eigen(g)
  )
  igraph::V(g)$.eigen_weighted <- label_clusters(
    "Ew",
    igraph::cluster_leading_eigen(g, weights = w)
  )
  igraph::V(g)$.label_prop <- label_clusters(
    "LP",
    igraph::cluster_label_prop(g)
  )
  igraph::V(g)$.label_prop_weighted <- label_clusters(
    "LPw",
    igraph::cluster_label_prop(g, weights = w)
  )
  g
}

if (sys.nframe() == 5) {
  g <- add_clustering(example_network_2)
  g |> print()
  igraph::vertex_attr(g) |> print()
}
