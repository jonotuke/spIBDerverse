utils::globalVariables(
  c("type")
)
#' Plot homophily
#'
#' @param RM Ringbauer tibble
#'
#' @return Plot of homophily density
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |> plot_homophily()
plot_homophily <- function(RM) {
  RM <- RM |>
    dplyr::filter(!is.nan(density))
  RM <- RM |>
    dplyr::mutate(
      type = ifelse(grp1 == grp2, "homophily", "heterophily")
    ) |>
    dplyr::mutate(
      name = stringr::str_glue("{grp1}-{grp2}")
    ) |>
    dplyr::mutate(name = forcats::fct_reorder(name, density))
  RM |>
    ggplot2::ggplot(
      ggplot2::aes(name, density, fill = type)
    ) +
    ggplot2::geom_point(pch = 21, size = 5) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = -90, hjust = 0)
    ) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::labs(y = "Density", x = "Edge", fill = NULL)
}
# pacman::p_load(conflicted, tidyverse, targets, ggrepel, igraph)
# get_ringbauer_measures(example_network, "site") |>
#   plot_homophily() |>
#   print()
