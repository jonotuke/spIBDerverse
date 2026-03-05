utils::globalVariables(
  c("mcmc.error")
)
#' Tab ergm coefficients
#'
#' @param ergms list of ergm fits
#' @param models models to show
#'
#' @return plot of coefficients
#' @export
#'
#' @examples
#' ergms <- get_ergms(
#'   example_network,
#'   preds = c("site", "genetic_sex"),
#'   types = c("nodematch", "nodemix")
#' )
#' ergms |> plot_ergm_coef()
tab_ergm_coef <- function(
  ergms,
  models = NULL
) {
  if (is.null(models)) {
    return(NULL)
  }
  coef <- ergms |>
    purrr::map(broom::tidy) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::group_by(Model) |>
    dplyr::select(-mcmc.error)
  coef <- coef |>
    dplyr::filter(Model %in% models)
  return(coef)
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# ergms <- get_ergms(
#   example_network,
#   preds = c("site", "genetic_sex"),
#   types = c("nodematch", "nodematch")
# )
# ergms
# models <- c(
#   "network ~ edges",
#   "network ~ edges + nodematch('site') + nodematch('genetic_sex')"
# )
# ergms |> tab_ergm_coef(models = models) |> print()
