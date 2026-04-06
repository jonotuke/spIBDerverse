utils::globalVariables(
  c(
    ".closeness",
    ".eigencentrality",
    "nodes",
    ".degree"
  )
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
    tibble::rownames_to_column(var = "vertex_id") |>
    tibble::as_tibble() |>
    dplyr::mutate(
      nodes = 1
    )
  df |>
    dplyr::group_by(
      dplyr::across(dplyr::any_of(var))
    ) |>
    dplyr::reframe(
      dplyr::across(c(dplyr::starts_with(".")), \(x) {
        mean(x, na.rm = TRUE)
      }),
      dplyr::across(nodes, sum),
    ) |>
    dplyr::relocate(nodes, .before = .degree)
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_centrality_measures(example_network) |> print()
