utils::globalVariables(".interaction")

#' Plot centrality measures
#'
#' Computes closeness, betweenness and eigenvector centrality for every vertex
#' of `g` and plots the chosen measure. Without `facets` a histogram of the
#' measure is drawn; with `facets` a boxplot is drawn for each combination of
#' the facet attributes, ordered by the median of the measure.
#'
#' @param g An igraph object.
#' @param measure Name of the centrality measure to plot. Either a vertex
#'   attribute of `g` (e.g. `".degree"`) or one of the computed measures:
#'   `"closeness"`, `"betweenness"` or `"eigen_centrality"`.
#' @param facets Optional character vector of vertex attributes to group by.
#' @param rotate If `TRUE`, rotate the x-axis labels by 90 degrees.
#'
#' @returns A ggplot object: a histogram if `facets` is `NULL`, otherwise a
#'   boxplot.
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' plot_centrality(example_network)
#' plot_centrality(example_network, "closeness", rotate = TRUE)
plot_centrality <- function(
  g,
  measure = ".degree",
  facets = NULL,
  rotate = FALSE
) {
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble() |>
    dplyr::mutate(
      vertex_id = as.character(igraph::V(g)),
      nodes = 1,
      closeness = igraph::closeness(g),
      betweenness = igraph::betweenness(g),
      eigen_centrality = igraph::eigen_centrality(g)$vector
    )

  missing_cols <- setdiff(c(measure, facets), names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Unknown measure or facet: ",
      stringr::str_c(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  if (is.null(facets)) {
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[measure]])) +
      ggplot2::geom_histogram(col = "white", fill = "black")
  } else {
    facet_label <- stringr::str_c(facets, collapse = "\n")

    df <- df |>
      dplyr::mutate(
        .interaction = interaction(df[facets], sep = "\n"),
        .interaction = forcats::fct_reorder(.interaction, .data[[measure]])
      )

    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(x = .interaction, y = .data[[measure]], fill = .interaction)
    ) +
      ggplot2::geom_boxplot() +
      ggplot2::labs(x = facet_label, fill = facet_label) +
      harrypotter::scale_fill_hp_d("Ravenclaw")
  }

  p <- p + ggplot2::theme_bw()

  if (rotate) {
    p <- p +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(angle = 90, hjust = 1, vjust = 0.5)
      )
  }

  p
}

if (sys.nframe() == 5) {
  plot_centrality(
    example_network_2,
    "closeness",
    c("Country", "Province"),
    rotate = TRUE
  ) |>
    print()
}
