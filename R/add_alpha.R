#' Add alpha
#'
#' @param g igraph network
#' @param measure centrality measure to set .alpha to
#'
#' @returns igraph network with an vertex attribute called .alpha set to give centrality
#' measure that can be used in [plot_ggnet]
#'
#' @export
#' @examples
#' add_alpha(example_network, "degree")
add_alpha <- function(g, measure = NULL) {
  stopifnot(
    measure %in%
      c(NULL, "degree", "closeness", "betweenness", "eigen_centrality")
  )
  igraph::V(g)$.id <- 1:igraph::vcount(g)
  if (!is.null(measure)) {
    igraph::V(g)$.alpha <-
      get_centrality_measures(g, ".id") |>
      dplyr::pull(measure)
  } else {
    igraph::V(g)$.alpha <- 1
  }
  g
}
# add_alpha(example_network)
