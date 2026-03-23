utils::globalVariables(
  c(".interaction")
)
#' plot centrality measures
#'
#' @param g igraph obj
#' @param measure centrality measure to plot
#' @param facets attributes to facet plot on
#'
#' @returns histogram or barchart
#'
#' @export
#' @examples
#' plot_centrality(example_network)
plot_centrality <- function(g, measure = "degree", facets = NULL) {
  df <- igraph::as_data_frame(g, what = "vertices") |>
    tibble::as_tibble() |>
    dplyr::mutate(vertex_id = as.character(igraph::V(g))) |>
    dplyr::mutate(
      nodes = 1,
      closeness = igraph::closeness(g),
      betweenness = igraph::betweenness(g),
      eigen_centrality = igraph::eigen_centrality(g)$vector
    )
  if (is.null(facets)) {
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[measure]])) +
      ggplot2::geom_histogram(col = "white", fill = "black")
  } else {
    interaction_term <- interaction(df[facets], sep = "\n")
    df <- df |>
      dplyr::mutate(
        .interaction = interaction_term,
        .interaction = forcats::fct_reorder(.interaction, .data[[measure]])
      )
    p <- df |>
      ggplot2::ggplot() +
      ggplot2::geom_boxplot(
        ggplot2::aes(
          x = .interaction,
          y = .data[[measure]],
          fill = .interaction
        )
      ) +
      ggplot2::labs(
        fill = stringr::str_c(facets, collapse = "\n"),
        x = stringr::str_c(facets, collapse = "\n")
      ) +
      harrypotter::scale_fill_hp_d("Ravenclaw")
  }
  p <- p + ggplot2::theme_bw()

  p
}
# plot_centrality(example_network, "closeness", c("site", "genetic_sex")) |>
#   print()
