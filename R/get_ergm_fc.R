utils::globalVariables(
  c("term", "estimate", "theta", "term")
)
theta_to_phi <- function(theta0, theta1) {
  p0 <- exp(theta0) / (1 + exp(theta0))
  p1 <- exp(theta0 + theta1) / (1 + exp(theta0 + theta1))
  p1 / p0
}
#' Convert ergm coefficients to fold changes
#'
#' The fold changes are all based on comparison to reference level
#'
#' @param ergm an ergm fit
#' @param trim whether to remove coefficients where the coefficient is -Inf
#'
#' @return tibble of fold changes
#' @export
#'
#' @examples
#' ergm <- get_ergms(example_network, preds = "site")
#' get_ergm_fc(ergm[[1]])
get_ergm_fc <- function(ergm, trim = TRUE) {
  coef <- ergm |>
    broom::tidy() |>
    dplyr::select(term, theta = estimate)
  theta_0 <- coef |>
    dplyr::filter(term == "edges") |>
    dplyr::pull(theta)
  coef <- coef |>
    dplyr::mutate(
      phi = dplyr::case_when(
        term == "edges" ~ theta_to_phi(theta_0, 0),
        TRUE ~ theta_to_phi(theta0 = theta_0, theta1 = theta)
      )
    )
  if (trim) {
    coef <- coef |> dplyr::filter(theta != -Inf)
  }
  coef
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# ergms <-
#   get_ergms(
#     example_network,
#     preds = c("site", "genetic_sex")
#   )
# ergms[[1]] |> get_ergm_fc() |> print()
