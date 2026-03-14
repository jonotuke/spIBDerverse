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
    stringr::str_remove_all(' ') |>
    stringr::str_replace_all("^network~edges$", "null model") |>
    stringr::str_remove_all("^.*~edges\\+") |>
    stringr::str_remove_all("'") |>
    stringr::str_replace_all('nodecov', 'sum') |>
    stringr::str_replace_all('absdiff', 'diff') |>
    stringr::str_replace_all("nodematch\\((.*),diff=TRUE\\)", "nodediff(\\1)")
}
