#' get_network_measures
#'
#' @param g igraph object
#' @param measure centrality measure to use
#' @param var vertex variables to stratify on
#'
#' @importFrom rlang :=
#'
#' @return summary table
#' @export
#'
#' @examples
#' get_network_measures(example_network, var = "site")
get_network_measures <- function(g, measure = "degree", var = "") {
  # Add measures
  igraph::V(g)$measure = dplyr::case_when(
    measure == "degree" ~ igraph::degree(g),
    measure == "eigen" ~ igraph::centr_eigen(g)$vector,
    TRUE ~ NA
  )
  name <- stringr::str_glue("mean ({measure})")
  igraph::as_data_frame(g, what = "vertices") |>
    dplyr::group_by(
      dplyr::across(dplyr::any_of(var))
    ) |>
    dplyr::summarise("{name}" := mean(measure))
}
# pacman::p_load(conflicted, tidyverse, targets)
# get_network_measures(
#   example_network,
#   var = c("genetic_sex", "site")
# ) |>
#   print()
