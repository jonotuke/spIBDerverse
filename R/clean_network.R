#' Clean network
#'
#' Removes all nodes with NAs for a given attribute
#' so can fit ERGM models
#'
#' @param g IBD igraph obj
#' @param col node attribute
#'
#' @return cleaned IBD igraph obj
#' @export
#'
#' @examples
#' clean_network(example_network_3, "site")
clean_network <- function(g, col) {
  index <- which(is.na(igraph::vertex_attr(g, col)))
  g <- igraph::delete_vertices(g, igraph::V(g)[index])
  g
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_network_summary(example_network_3) |> print()
# example_network_3 <- clean_network(example_network_3, "site") |> print()
# get_network_summary(example_network_3) |> print()
# example_network_3 <- clean_network(example_network_3, "genetic_sex") |> print()
# get_network_summary(example_network_3) |> print()
