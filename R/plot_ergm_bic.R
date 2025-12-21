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
#' @param measure decide if AIC or BIC.
#' @param top_5 boolean to show just top 5 models
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
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
) {
  n_coef <- ergms |>
    purrr::map(broom::tidy) |>
    purrr::map(\(x) tibble::tibble(n_coef = nrow(x))) |>
    purrr::list_rbind(names_to = "model")
  model_summaries <- ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "model") |>
    dplyr::left_join(n_coef, by = "model")
  model_summaries <- model_summaries |>
    dplyr::arrange(n_coef, .data[[measure]]) |>
    dplyr::mutate(xrel = 1:dplyr::n())
  if (top_5) {
    model_summaries <- model_summaries |> dplyr::slice(1:5)
  }
  rect_tab <- model_summaries |>
    dplyr::group_by(n_coef) |>
    dplyr::summarise(
      xmin = min(xrel) - 0.5,
      xmax = max(xrel) + 0.5,
    )
  if (abbr) {
    model_summaries <- model_summaries |>
      dplyr::mutate(
        model = clean_models(model)
      )
  }
  model_summaries |>
    dplyr::mutate(best = .data[[measure]] == min(.data[[measure]])) |>
    ggplot2::ggplot(
      ggplot2::aes(x = xrel, y = .data[[measure]], group = 1)
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
      data = model_summaries |>
        dplyr::filter(.data[[measure]] == min(.data[[measure]])),
      pch = 19,
      size = 5,
      col = 'red'
    ) +
    ggplot2::geom_text(
      data = model_summaries |>
        dplyr::filter(.data[[measure]] == min(.data[[measure]])),
      ggplot2::aes(label = n_coef),
      col = 'black'
    ) +
    ggplot2::scale_x_continuous(
      breaks = model_summaries$xrel,
      labels = model_summaries$model,
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
    # ggplot2::labs(x = NULL, y = measure)
    ggplot2::xlab(NULL)
}
# pacman::p_load(conflicted, tidyverse, targets)
# ergms <- example_network |>
#   get_ergms(c("site", "genetic_sex", "degree"))
# ergms
# plot_ergm_bic(ergms, abbr = TRUE) |> print()
