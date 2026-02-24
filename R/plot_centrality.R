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
  p <- df |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = .data[[measure]]
      )
    )
  if (measure == "degree") {
    p <- p + ggplot2::geom_bar()
  } else {
    p <- p + ggplot2::geom_histogram(col = "white", fill = "black")
  }
  p <- p + ggplot2::theme_bw()
  if (!is.null(facets)) {
    p <- p + ggplot2::facet_wrap(facets)
  }
  p
}
# plot_centrality(example_network, "degree", c("genetic_sex", "site")) |>
#   print()
