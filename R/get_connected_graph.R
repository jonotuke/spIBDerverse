#' get_connected_graph
#'
#' @param g igraph object
#'
#' @return igraph object
#' @export
#'
#' @examples
#' g <- igraph::sample_gnp(10, 0.5)
#' get_connected_graph(g)
get_connected_graph <- function(g) {
  components <- igraph::components(g, mode = "weak")
  connected_cluster_id <- which(components$csize > 1)
  node_id <- igraph::V(g)[components$membership %in% connected_cluster_id]
  igraph::induced_subgraph(g, node_id)
}
