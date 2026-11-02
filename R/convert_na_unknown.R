#' converts NA to unknown
#'
#' @param g igraph object
#' @param name node attribute to convert
#'
#' @returns updated igraph object
#'
#' @export
#' @examples
#' convert_na_unknown(example_network_3, "site")
convert_na_unknown <- function(g, name) {
  names <- get_node_attributes(g)
  if (!name %in% names) {
    stop(
      stringr::str_glue("{name} is not a node attribute")
    )
  }
  x <- igraph::vertex_attr(g, name)
  x[is.na(x)] <- "Unknown"
  igraph::set_vertex_attr(g, name, value = x)
}
#' converts all NAs in node attributes
#'
#' @param g igraph object
#'
#' @returns igraph object with all NAs converted
#'
#' @export
#' @examples
#' convert_nas_unknown(example_network_3)
convert_nas_unknown <- function(g) {
  names <- get_node_attributes(g)
  for (i in names) {
    g <- convert_na_unknown(g, i)
  }
  g
}
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets, igraph)
  g <- convert_na_unknown(example_network_3, "site")
  g <- convert_nas_unknown(g)
  V(example_network_3)$site
  V(example_network_3)$genetic_sex
  V(g)$site
  V(g)$genetic_sex
}
