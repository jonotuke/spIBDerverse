#' Plot model fits
#'
#' @param ergms list of ergms fitted to IBD net
#' @param type which plot to show
#'
#' @return plot of fits
#' @export
#'
#' @examples
#' example_network |>
#' get_ergms(c("site", "genetic_sex")) |>
#' plot_ergm_bic()
plot_ergm_bic <- function(ergms, type = 1) {
  if (type == 1) {
    fig <- plot_ergm_bic_JT(ergms)
  }
  fig
}
# pacman::p_load(conflicted, tidyverse, targets)
# example_network |>
#   get_ergms(c("site", "genetic_sex")) |>
#   plot_ergm_bic() |>
#   print()
