utils::globalVariables(
  c(
    "mcmc.error",
    "phi",
    "std.error",
    "statistic",
    "p.value"
  )
)
#' Gets coefficients and fold changes for a ergm model
#'
#' @param ergm ergm model
#'
#' @returns coefficient table
#'
#' @export
#' @examples
#' ergms <- get_ergms(
#' example_network,
#' preds = c("site", "genetic_sex"),
#' types = c("nodematch", "nodematch")
#' )
#' ergms[[1]] |> get_ergm_coef()
get_ergm_coef <- function(ergm) {
  coef <- broom::tidy(ergm)
  fc <- get_ergm_fc(ergm)
  coefs <- coef |> dplyr::left_join(fc, by = "term")
  coefs |>
    dplyr::select(
      term,
      coef = theta,
      fold_change = phi,
      std.error,
      statistic,
      p.value
    )
}
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
    purrr::map(get_ergm_coef) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::group_by(Model) |>
    dplyr::filter(Model %in% models) |>
    dplyr::mutate(sign = add_stars(p.value))
  return(coef)
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# ergms <- get_ergms(
#   example_network,
#   preds = c("site", "genetic_sex"),
#   types = c("nodematch", "nodematch")
# )
# ergms
# ergms |>
#   tab_ergm_coef(
#     models = c(
#       "network ~ edges",
#       "network ~ edges + nodematch('site') + nodematch('genetic_sex')"
#     )
#   ) |>
#   print()
