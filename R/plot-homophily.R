utils::globalVariables(
  c("n1", "n2")
)
plot_homophily <- function(g, col) {
  df <- g |>
    get_ringbauer_measures(col)
  df |>
    ggplot2::ggplot() +
    ggplot2::geom_segment(
      ggplot2::aes(x = 1, xend = 2, y = density, yend = density),
      linewidth = 2,
      linetype = "dashed"
    ) +
    ggrepel::geom_text_repel(
      ggplot2::aes(x = 1, y = density, label = grp1),
      nudge_x = -0.5
    ) +
    ggrepel::geom_text_repel(
      ggplot2::aes(x = 2, y = density, label = grp2),
      nudge_x = +0.5
    ) +
    ggplot2::geom_point(
      ggplot2::aes(x = 1, y = density, fill = grp1, size = n1),
      pch = 21
    ) +
    ggplot2::geom_point(
      ggplot2::aes(x = 2, y = density, fill = grp2, size = n2),
      pch = 21,
    ) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.line.x = ggplot2::element_blank(), # Remove x-axis line
      axis.text.x = ggplot2::element_blank(), # Remove x-axis tick labels
      axis.ticks.x = ggplot2::element_blank(), # Remove x-axis ticks
      axis.title.x = ggplot2::element_blank(), # Remove x-axis title
      panel.grid.minor = ggplot2::element_blank(), # Remove minor grid lines
      panel.grid.major = ggplot2::element_blank(), # Remove major grid lines
      panel.background = ggplot2::element_blank(), # Remove panel background
      plot.background = ggplot2::element_blank(), # Remove plot background
      legend.position = "none" # Remove any legends
    ) +
    ggplot2::xlim(0, 3)
}
# pacman::p_load(conflicted, tidyverse, targets)
# plot_homophily(example_network, "site") |> print()
# plot_homophily(example_network_2, "Locality") |> print()
