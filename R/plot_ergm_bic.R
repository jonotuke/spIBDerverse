utils::globalVariables(
  c("xrel", "xmin", "xmax", "model")
)
#' Plots BIC
#'
#' Final version is based on BR's version
#'
#' @param ergms a list of ergms
#' @param text_size size of x axis text
#' @param text_angle angle of x-axis text
#' @param abbr boolean to clean up names
#'
#' @return plot
#' @export
#'
#' @examples
#' ergms <- example_network |>
#'   get_ergms(c("site", "genetic_sex"))
#' plot_ergm_bic(ergms) |> print()
plot_ergm_bic <- function(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE
) {
  n_coef <- ergms |>
    purrr::map(broom::tidy) |>
    purrr::map(\(x) tibble::tibble(n_coef = nrow(x))) |>
    purrr::list_rbind(names_to = "model")
  bic <- ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "model") |>
    dplyr::left_join(n_coef, by = "model")
  bic <- bic |>
    dplyr::arrange(n_coef, BIC) |>
    dplyr::mutate(xrel = 1:dplyr::n())
  rect_tab <- bic |>
    dplyr::group_by(n_coef) |>
    dplyr::summarise(
      xmin = min(xrel) - 0.5,
      xmax = max(xrel) + 0.5,
    )
  if (abbr) {
    bic <- bic |>
      dplyr::mutate(
        model = clean_models(model)
      )
  }
  bic |>
    dplyr::mutate(best = BIC == min(BIC)) |>
    ggplot2::ggplot(
      ggplot2::aes(x = xrel, y = BIC, group = 1)
    ) +
    ggplot2::theme_bw() +
    ggplot2::geom_rect(
      inherit.aes = FALSE,
      data = rect_tab,
      ggplot2::aes(
        ymin = -Inf,
        ymax = Inf,
        xmin = xmin,
        xmax = xmax,
        alpha = n_coef
      )
    ) +
    ggplot2::geom_line(linetype = 'dashed') +
    ggplot2::geom_point(pch = 19, size = 6) +
    ggplot2::geom_text(ggplot2::aes(label = n_coef), col = 'white') +
    ggplot2::geom_point(
      data = bic |> dplyr::filter(BIC == min(BIC)),
      pch = 19,
      size = 5,
      col = 'red'
    ) +
    ggplot2::geom_text(
      data = bic |> dplyr::filter(BIC == min(BIC)),
      ggplot2::aes(label = n_coef),
      col = 'black'
    ) +
    ggplot2::scale_x_continuous(
      breaks = bic$xrel,
      labels = bic$model,
      expand = c(0, 0)
    ) +
    ggplot2::scale_alpha_continuous(
      range = c(0.1, 0.5),
      name = '# coeffcients'
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = text_angle,
        hjust = 1
      ),
      legend.position = 'none',
      axis.text = ggplot2::element_text(size = text_size)
    ) +
    ggplot2::xlab(NULL)
}
# pacman::p_load(conflicted, tidyverse, targets)
# ergms <- example_network |>
#   get_ergms(c("site", "genetic_sex"))
# ergms
# plot_ergm_bic_BR(ergms, abbr = TRUE) |> print()
