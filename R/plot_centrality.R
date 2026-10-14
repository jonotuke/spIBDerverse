utils::globalVariables(".interaction")

#' Plot centrality measures
#'
#' Computes closeness, betweenness and eigenvector centrality for every vertex
#' of `g` and plots the chosen measure. Without `preds` a histogram of the
#' measure is drawn; with `preds` a boxplot is drawn for each combination of
#' the facet attributes, ordered by the median of the measure.
#'
#' @param g An igraph object.
#' @param centrality centrality measures
#' @param preds Preditors for centrality
#' @param rotate If `TRUE`, rotate the x-axis labels by 90 degrees.
#'
#' @returns A ggplot object: a histogram if `preds` is `NULL`, otherwise a
#'   boxplot.
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' plot_centrality(example_network)
#' plot_centrality(example_network, ".closeness", rotate = TRUE)
plot_centrality <- function(
  g,
  centrality = ".degree",
  preds = NULL,
  rotate = FALSE
) {
  # Convert g to df
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble()

  # Check for centrality measures and preds in graph attributes
  missing_cols <- setdiff(c(centrality, preds), names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Unknown centrality or preds: ",
      stringr::str_c(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  df <- df |>
    tidyr::pivot_longer(
      tidyr::all_of(centrality),
      names_to = ".centrality"
    )
  if (is.null(preds)) {
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = value)
    ) +
      ggplot2::geom_histogram(col = "white", fill = "black") +
      ggplot2::facet_wrap(~.centrality, scales = "free", ncol = 2)
  } else {
    facet_label <- stringr::str_c(preds, collapse = "\n")

    df <- df |>
      dplyr::mutate(
        .interaction = interaction(df[preds], sep = "\n"),
        .interaction = forcats::fct_reorder(.interaction, value)
      )

    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .interaction, y = value, fill = .interaction)
    ) +
      ggplot2::geom_boxplot() +
      ggplot2::labs(x = facet_label, fill = facet_label) +
      harrypotter::scale_fill_hp_d("Ravenclaw") +
      ggplot2::facet_wrap(~.centrality, scales = "free")
  }

  p <- p + ggplot2::theme_bw()

  if (rotate) {
    p <- p +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(
          angle = 90,
          hjust = 1,
          vjust = 0.5
        )
      )
  }

  p
}

if (sys.nframe() == 5) {
  plot_centrality(
    example_network,
    c(
      ".degree",
      ".closeness",
      ".betweenness",
      ".eigencentrality"
    ),
    c("genetic_sex", "site")
  ) |>
    print()
}
