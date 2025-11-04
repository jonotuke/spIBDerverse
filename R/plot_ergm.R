utils::globalVariables(
  c("Model", "BIC", "value")
)
plot_ergm_bic <- function(ergms) {
  ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::select(Model, BIC) |>
    tidyr::pivot_longer(-Model) |>
    dplyr::mutate(Model = forcats::fct_reorder(Model, -value)) |>
    ggplot2::ggplot(
      ggplot2::aes(value, Model, fill = name)
    ) +
    ggplot2::geom_line(
      ggplot2::aes(group = name)
    ) +
    ggplot2::geom_point(pch = 21, size = 3) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::theme_bw() +
    ggplot2::geom_vline(
      ggplot2::aes(xintercept = min(value)),
      linetype = "dashed",
      linewidth = 2
    ) +
    ggplot2::labs(x = "AIC/BIC", y = NULL, fill = "Measure") +
    ggplot2::theme(legend.position = c(0.9, 0.9))
}
plot_ergm_coef <- function(
  ergms,
  type = "theta",
  trim = TRUE
) {
  if (type == "theta") {
    xlab = "Coefficient of ERGM"
  } else {
    xlab = "Fold change compared to edges"
  }
  ergms |>
    purrr::map(get_ergm_fc, trim = trim) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::group_by(Model) |>
    dplyr::mutate(
      term = tidytext::reorder_within(term, .data[[type]], Model),
      sign = ifelse(.data[[type]] >= 0, "+ve", "-ve")
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(.data[[type]], term, fill = sign)
    ) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::facet_wrap(
      ~Model,
      scales = "free_y",
      space = "free_y",
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
#   preds = c("site", "genetic_sex")
# )
# ergms |> plot_ergm_bic() |> print()
# ergms |> plot_ergm_coef() |> print()
