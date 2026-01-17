utils::globalVariables(
  c("closeness", "eigen_centrality")
)
#' Get centrality measures
#'
#' @description
#' Gives a table of mean centrality measures
#' given a list of vertex attributes to stratify
#' on. If not list given then gives overall.
#'
#'
#' @param g igraph object
#' @param var character vector of attributes to stratify on
#'
#' @returns tibble of centrality measures
#'
#' @export
#' @examples
#' get_centrality_measures(example_network, c("site", "genetic_sex"))
get_centrality_measures <- function(g, var = NULL) {
  if (is.null(var)) {
    var <- "vertex_id"
  }
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble() |>
    dplyr::mutate(vertex_id = as.character(igraph::V(g))) |>
    dplyr::mutate(
      closeness = igraph::closeness(g),
      betweenness = igraph::betweenness(g),
      eigen_centrality = igraph::eigen_centrality(g)$vector
    )
  df |>
    dplyr::group_by(
      dplyr::across(dplyr::any_of(var))
    ) |>
    dplyr::reframe(
      dplyr::across(c(degree, closeness:eigen_centrality), mean)
    )
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_centrality_measures(example_network, c("site", "genetic_sex")) |> print()
# get_centrality_measures(example_network) |> print()
