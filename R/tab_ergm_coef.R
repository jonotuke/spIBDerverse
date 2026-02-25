#' Tab ergm coefficients
#'
#' @param ergms list of ergm fits
#' @param type either "theta" or "phi" - fold changes
#' @param trim remove -Inf coefficients
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
  type = "theta",
  trim = TRUE,
  models = NULL
) {
  if (type == "theta") {
    xlab = "Coefficient of ERGM"
    cutoff <- 0
  } else {
    xlab = "Fold change compared to edges"
    cutoff <- 1
  }
  if (is.null(models)) {
    return(NULL)
  }
  coef <- ergms |>
    purrr::map(get_ergm_fc, trim = trim) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::group_by(Model)
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
