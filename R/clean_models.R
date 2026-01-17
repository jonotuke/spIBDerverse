#' clean model names
#'
#' @param x vector of ergm model names
#'
#' @return cleaned vector
#' @export
#'
#' @examples
#' ergms <- example_network |>
#'   get_ergms(c("site", "genetic_sex"), c("nodemix", "nodematch")) |>
#'   purrr::map(broom::glance) |>
#'   purrr::list_rbind(names_to = "model")
#' clean_models(ergms$model) |> print()
clean_models <- function(x) {
  x |>
    stringr::str_remove_all("network ~ ") |>
    stringr::str_replace_all(" \\+ ", "|") |>
    stringr::str_replace_all("nodemix", "NM") |>
    stringr::str_replace_all("nodecov", "NC") |>
    stringr::str_remove_all("'")
}
# pacman::p_load(conflicted, tidyverse, targets)
# ergms <- example_network |>
#   get_ergms(c("site", "genetic_sex")) |>
#   map(broom::glance) |>
#   list_rbind(names_to = "model")
# clean_models(ergms$model) |> print()
