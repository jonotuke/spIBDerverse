#' remove redundant models
#'
#' @param models list of models
#' @param vars list of variables to filter on
#'
#' @returns list so each var appears only once
#'
#' @export
#' @examples
#' M1 <- "network ~ edges + nodematch('A') + nodemix('A')"
#' M2 <- "network ~ edges + nodematch('A')"
#' remove_redundant_models(list(M1, M2), "A")
remove_redundant_models <- function(models, vars) {
  for (var in vars) {
    models <- models |>
      purrr::discard(\(x) stringr::str_count(x, var) > 1)
  }
  models
}
# M1 <- "network ~ edges + nodematch('A') + nodemix('A')"
# M2 <- "network ~ edges + nodematch('A')"
# remove_redundant_models(list(M1, M2), vars = "A")
