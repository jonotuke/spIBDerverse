#' plot centrality measures
#'
#' @param g igraph obj
#' @param measure centrality measure to plot
#'
#' @returns histogram or barchart
#'
#' @export
#' @examples
#' plot_centrality(example_network)
plot_centrality <- function(g, measure = "degree") {
  p <- g |>
    get_centrality_measures() |>
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
  p
}
# plot_centrality(example_network_2, "closeness") |> print()
