#' Get network node information
#'
#' @param g ibd network object
#'
#' @return tibble of node information
#' @export
#'
#' @examples
#' get_node_info(example_network)
get_node_info <- function(g) {
  igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_node_info(example_network) |> print()
