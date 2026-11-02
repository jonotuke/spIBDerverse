#' add layout
#'
#' @param g igraph network
#' @param name name of layout
#'
#' @returns coords based on igraph layout
#'
#' @export
#' @examples
#' add_layout(example_network)
add_layout <- function(g, name = "nicely") {
  if (name == "circle") {
    igraph::layout_in_circle(g)
  } else if (name == "sphere") {
    igraph::layout_on_sphere(g)
  } else if (name == "dh") {
    igraph::layout_with_dh(g)
  } else if (name == "fr") {
    igraph::layout_with_fr(g)
  } else if (name == "kk") {
    igraph::layout_with_kk(g)
  } else if (name == "mds") {
    igraph::layout_with_mds(g)
  } else {
    igraph::layout_nicely(g)
  }
}

if (sys.nframe() == 5) {
  set.seed(2026)
  pacman::p_load(conflicted, tidyverse, targets, ggnetwork)
  add_layout(example_network) |> print()
  layout <- add_layout(example_network, "mds")
  p <- example_network |>
    ggnetwork(layout = layout) |>
    ggplot(aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_edges() +
    geom_nodes(
      aes(
        fill = site
      ),
      col = 'black',
      size = 5,
      pch = 21
    ) +
    geom_nodetext(aes(label = name), size = 3, col = "white") +
    theme_blank() +
    harrypotter::scale_fill_hp_d("Ravenclaw")
  p |> print()
}
