#' Get network edge information
#'
#' @param g ibd network object
#'
#' @return tibble of node information
#' @export
#'
#' @examples
#' get_edge_info(example_network_2)
get_edge_info <- function(g) {
  igraph::as_data_frame(g, what = "edges") |>
    tibble::as_tibble() |>
    dplyr::mutate(
      dplyr::across(dplyr::starts_with("frac"), \(x) round(x, 4)),
      dplyr::across(dplyr::starts_with("max"), \(x) round(x, 2)),
      dplyr::across(dplyr::starts_with("sum"), \(x) round(x, 2)),
      dplyr::across(wij, \(x) round(x, 2)),
    )
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_edge_info(example_network_2) |> glimpse()
