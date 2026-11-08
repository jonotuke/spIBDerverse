utils::globalVariables(
  c(
    "density",
    "adj_pv",
    "lwr",
    "upr",
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
#' @param ci Logical. If `TRUE`, add 95% CI error bars for the proportions
#'   (requires `lwr` and `upr` columns in `RM`).
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
  sig_level = 0.05,
  ci = FALSE
) {
  if (ci && !all(c("lwr", "upr") %in% names(RM))) {
    stop("`ci = TRUE` requires `lwr` and `upr` columns in `RM`.", call. = FALSE)
  }

  overall_density <- RM$overall_density[1]

  edges <- RM |>
    # Drop missing densities
    dplyr::filter(!is.na(density)) |>
    # Label groups so repeated (A-B / B-A) edges collapse together
    label_grp_duplicates(grp1, grp2) |>
    dplyr::ungroup() |>
    dplyr::summarise(
      dplyr::across(
        dplyr::any_of(c("density", "adj_pv", "lwr", "upr")),
        mean
      ),
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

  p <- ggplot2::ggplot(edges, ggplot2::aes(name, density, fill = type)) +
    ggplot2::geom_hline(
      yintercept = overall_density,
      linewidth = 1,
      linetype = "dashed"
    )

  if (ci) {
    p <- p +
      ggplot2::geom_errorbar(
        ggplot2::aes(ymin = lwr, ymax = upr, alpha = faded),
        width = 0.1
      )
  }

  p +
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
#' sort labels
#'
#' @description
#' Takes two labels and sorts them so for example
#' A and B becomes A-B, and B and A becomes A-B.
#' This means that you can find duplicate edges in
#' an undirected network as they will have the same
#' label
#'
#'
#' @param label1 first label
#' @param label2 second label
#'
#' @returns label of form first-second
#'
#' @export
#' @examples
#' sort_label("A", "B")
#' sort_label("B", "A")
sort_label <- function(label1, label2) {
  c(label1, label2) |>
    sort() |>
    stringr::str_c(collapse = "==")
}
#' label_grp_duplicates
#'
#' @param df data frame with two group columns
#' @param grp1 name of first group col
#' @param grp2 name of second group col
#'
#' @returns df with extra col called .grp_label that has can be
#' used to remove duplicated rows
#'
#' @export
#' @examples
#' df <- tidyr::expand_grid(
#'   grp1 = LETTERS[1:3],
#'   grp2 = LETTERS[1:3]
#' ) |>
#' dplyr::mutate(
#'   value = 1:9
#' )
#' label_grp_duplicates(df, grp1, grp2)
label_grp_duplicates <- function(df, grp1, grp2) {
  df |>
    dplyr::rowwise() |>
    dplyr::mutate(
      .grp_label = sort_label({{ grp1 }}, {{ grp2 }})
    )
}
