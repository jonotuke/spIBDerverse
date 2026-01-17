#' Plot ergm coefficients
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
plot_ergm_coef <- function(
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
    dplyr::group_by(Model) |>
    dplyr::mutate(
      term = tidytext::reorder_within(term, .data[[type]], Model),
      sign = ifelse(.data[[type]] > cutoff, "+ve", "-ve")
    )
  coef <- coef |>
    dplyr::filter(Model %in% models)
  coef |>
    ggplot2::ggplot(
      ggplot2::aes(.data[[type]], term, fill = sign)
    ) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::facet_wrap(
      ~Model,
      scales = "free_y",
      # space = "free_y",
      ncol = 1
    ) +
    tidytext::scale_y_reordered() +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::theme_bw() +
    ggplot2::labs(x = xlab)
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# ergms <- get_ergms(
#   example_network,
#   preds = c("site", "genetic_sex"),
#   types = c("nodematch", "nodematch")
# )
# models <- "network ~ edges"
# ergms |> plot_ergm_coef(models = models) |> print()
