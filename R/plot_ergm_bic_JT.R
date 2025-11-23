plot_ergm_bic_JT <- function(ergms) {
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
