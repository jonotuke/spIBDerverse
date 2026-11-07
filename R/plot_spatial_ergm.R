#' plot spatial ergm
#'
#' @param spatial_pred predict tibble from spatial ergm
#' @param pred predictor to colour by
#'
#' @returns ggplot
#'
#' @export
#' @examples
#' ergms <- fit_spatial_ergm(
#' example_network_5,
#' "Latitude",
#' "Longitude",
#' "period"
#' )
#' ergms$model[[3]] |>
#'  predict_spatial_ergm(N = 100) |>
#'  plot_spatial_ergm("period")
plot_spatial_ergm <- function(spatial_pred, pred = NULL) {
  spatial_pred |>
    ggplot2::ggplot(
      mapping = ggplot2::aes(
        x = distance,
        y = p,
        col = .data[[pred]],
        fill = .data[[pred]]
      )
    ) +
    ggplot2::theme_bw() +
    ggplot2::geom_ribbon(
      mapping = ggplot2::aes(ymin = lower, ymax = upper),
      alpha = 0.5
    ) +
    ggplot2::geom_line(linetype = 'dashed') +
    ggplot2::scale_x_continuous(name = 'Distance (km)') +
    ggplot2::scale_y_continuous(name = 'Probability of Connectedness') +
    ggsci::scale_colour_startrek(name = pred) +
    ggsci::scale_fill_startrek(name = pred)
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  ergms <- fit_spatial_ergm(
    example_network_5,
    "Latitude",
    "Longitude",
    "period"
  )
  ergms$model[[3]] |>
    predict_spatial_ergm(N = 100) |>
    plot_spatial_ergm("period") |>
    print()
}
