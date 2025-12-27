utils::globalVariables(
  c("type", "adj_pv", "pv", ".grp_label")
)
#' Plot homophily
#'
#' @param RM Ringbauer tibble
#' @param show_sign boolean on whether to colour by significance
#' @param filter_sign boolean to show only significant edges
#'
#' @return Plot of homophily density
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |> plot_homophily()
plot_homophily <- function(RM, show_sign = FALSE, filter_sign = FALSE) {
  # Remove missing densities
  RM <- RM |>
    dplyr::filter(!is.nan(density))
  # Add group labels so can remove repeated edges
  RM <- RM |>
    label_grp_duplicates(grp1, grp2)
  # Get summary for each edge type
  RM <- RM |>
    dplyr::ungroup() |>
    dplyr::summarise(
      density = mean(density),
      adj_pv = mean(adj_pv),
      .by = .grp_label
    )
  # Get groups back
  RM <- RM |>
    tidyr::separate(
      .grp_label,
      into = c("grp1", "grp2"),
    )
  RM <- RM |>
    dplyr::mutate(
      type = ifelse(grp1 == grp2, "within", "between")
    ) |>
    dplyr::mutate(
      name = stringr::str_glue("{grp1}-{grp2}")
    ) |>
    dplyr::mutate(name = forcats::fct_reorder(name, density))
  if (show_sign) {
    RM <- RM |>
      dplyr::mutate(
        type = ifelse(
          adj_pv <= 0.05,
          "significant",
          "not significant"
        )
      )
  }
  if (filter_sign) {
    RM <- RM |> dplyr::filter(adj_pv <= 0.05)
  }
  p <- RM |>
    ggplot2::ggplot(
      ggplot2::aes(name, density, fill = type)
    ) +
    ggplot2::geom_point(pch = 21, size = 5) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = -90, hjust = 0)
    ) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::labs(y = "Connectivity", x = "Edge", fill = NULL)
  p
}
# pacman::p_load(conflicted, tidyverse, targets, ggrepel, igraph)
# get_ringbauer_measures(example_network, "site") |>
#   plot_homophily(show_sign = TRUE, filter_sign = TRUE) |>
#   print()
