utils::globalVariables(
  c(
    "density",
    "adj_pv",
    "grp1",
    "grp2",
    "name",
    "type",
    "significant",
    "faded",
    ".grp_label"
  )
)

#' Plot homophily
#'
#' Plots the mean connectivity (density) of each edge type, with a dashed
#' reference line at the overall network density.
#'
#' @param RM A tibble of Ringbauer measures, as returned by
#'   [get_ringbauer_measures()].
#' @param show_sign Logical. If `TRUE`, colour points by significance
#'   instead of by within/between-group edge type.
#' @param filter_sign Logical. If `TRUE`, fade out non-significant edges.
#' @param sig_level Significance threshold applied to the adjusted p-values.
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' get_ringbauer_measures(example_network, "site") |> plot_homophily()
plot_homophily <- function(
  RM,
  show_sign = FALSE,
  filter_sign = FALSE,
  sig_level = 0.05
) {
  overall_density <- RM$overall_density[1]
  edges <- RM |>
    # Drop missing densities
    dplyr::filter(!is.na(density)) |>
    # Label groups so repeated (A-B / B-A) edges collapse together
    label_grp_duplicates(grp1, grp2) |>
    dplyr::ungroup() |>
    dplyr::summarise(
      density = mean(density),
      adj_pv = mean(adj_pv),
      .by = .grp_label
    ) |>
    tidyr::separate_wider_delim(
      .grp_label,
      delim = "==",
      names = c("grp1", "grp2")
    ) |>
    dplyr::mutate(
      significant = adj_pv <= sig_level,
      type = if (show_sign) {
        dplyr::if_else(significant, "significant", "not significant")
      } else {
        dplyr::if_else(grp1 == grp2, "within", "between")
      },
      faded = filter_sign & !significant,
      name = forcats::fct_reorder(stringr::str_glue("{grp1}-{grp2}"), density)
    )

  palette <- if (show_sign) "Hufflepuff" else "Ravenclaw"

  ggplot2::ggplot(edges, ggplot2::aes(name, density, fill = type)) +
    ggplot2::geom_hline(
      yintercept = overall_density,
      linewidth = 1,
      linetype = "dashed"
    ) +
    ggplot2::geom_point(
      ggplot2::aes(alpha = faded),
      shape = 21,
      size = 5
    ) +
    ggplot2::scale_alpha_manual(
      values = c(`FALSE` = 1, `TRUE` = 0.2),
      guide = "none"
    ) +
    harrypotter::scale_fill_hp_d(palette) +
    ggplot2::labs(x = "Edge", y = "Connectivity", fill = NULL) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = -90, hjust = 0)
    )
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  get_ringbauer_measures(example_network, "site") |>
    plot_homophily(show_sign = TRUE, filter_sign = TRUE) |>
    print()
}
