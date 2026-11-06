#' Get geodistance for points in network
#'
#' @param g igraph object
#' @param lat node attribute that is lat
#' @param long node attribute that is long
#'
#' @returns distance matrix in km's
#'
#' @export
#' @examples
#' get_dist(example_network, "lat", "long")
get_dist <- function(g, lat, long) {
  D <- geo_dist_matrix <- cbind(
    igraph::vertex_attr(g, long),
    igraph::vertex_attr(g, lat)
  ) |>
    geosphere::distm(fun = geosphere::distGeo)
  D <- D / 1000
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  get_dist(example_network, "lat", "long")
}
