#' Plot single ergm coefficients
#'
#' @param ergm ergm model
#' @param type either "theta" or "phi" - fold changes
#' @param trim remove -Inf coefficients
#'
#' @return plot of coefficients
#' @export
#'
#' @examples
#' ergms <- get_ergms(
#'   example_network,
#'   preds = c("site", "genetic_sex")
#' )
#' ergms[[1]] |> plot_single_ergm_coef()
plot_single_ergm_coef <- function(
  ergm,
  type = "theta",
  trim = TRUE
) {
  if (type == "theta") {
    xlab = "Coefficient of ERGM"
    cutoff <- 0
  } else {
    xlab = "Fold change compared to edges"
    cutoff <- 1
  }
  coef <- get_ergm_fc(ergm, trim = trim) |>
    dplyr::mutate(
      term = forcats::fct_reorder(term, .data[[type]]),
      sign = ifelse(.data[[type]] > cutoff, "+ve", "-ve")
    )
  coef |>
    ggplot2::ggplot(
      ggplot2::aes(.data[[type]], term, fill = sign)
    ) +
    ggplot2::geom_col(show.legend = FALSE) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::theme_bw() +
    ggplot2::labs(x = xlab)
}
# ergms <- get_ergms(
#   example_network,
#   preds = c("site", "genetic_sex")
# )
# ergms[[1]] |> plot_single_ergm_coef() |> print()
