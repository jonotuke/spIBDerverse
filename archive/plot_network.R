utils::globalVariables(
  c(
    ".data",
    "degree",
    "x",
    "y",
    "xend",
    "yend",
    "fill_col",
    "shape_col",
    "name",
    "alpha"
  )
)
#' plot ggnet
#'
#' @param g network
#' @param fill_col vertex attribute for node fill
#' @param shape_col vertex attribute for node shape
#' @param node_alpha_col vertext attribute for node alpha
#' @param node_size node size
#' @param edge_col edge attribute for line colour
#' @param edge_legend boolean to control edge legend
#' @param edge_trans transformation for edge mapping
#' @param text_size label size
#' @param text_col text colour
#' @param labels add labels
#' @param label_col vertex attribute to use for labels
#' @param label_inc regular expression to include labels
#' @param label_exc regular expression to exclude labels
#' @param connected choice for how to deal with isolated nodes with choices
#' Hide, Show, Grey out
#'
#' @return network plot
#' @export
#'
#' @examples
#' plot_network(example_network)
plot_network <- function(
  g,
  fill_col = "none",
  shape_col = "none",
  node_alpha_col = "none",
  edge_col = "none",
  edge_trans = "identity",
  edge_legend = TRUE,
  node_size = 4,
  text_size = 4,
  text_col = "black",
  labels = FALSE,
  label_col = "",
  label_inc = "",
  label_exc = "",
  connected = "Show"
) {
  ggplot2::update_geom_defaults(
    "point",
    list(shape = 21, fill = "white")
  )
  g <- ggnetwork::ggnetwork(g)
  if (label_col != "") {
    label_col <- rlang::sym(label_col)
    g <-
      g |>
      dplyr::mutate(
        name = {{ label_col }}
      )
  }
  # Clean labels
  if (label_inc != "") {
    label_inc <- convert_pipe(label_inc)
    g <- g |>
      dplyr::mutate(
        name = dplyr::case_when(
          stringr::str_detect(name, label_inc) ~ name,
          TRUE ~ NA
        )
      )
  }
  if (label_exc != "") {
    label_exc <- convert_pipe(label_exc)
    g <- g |>
      dplyr::mutate(
        name = dplyr::case_when(
          stringr::str_detect(name, label_exc) ~ NA,
          TRUE ~ name
        )
      )
  }
  if (!labels) {
    g$name <- NA
  }
  # Add alpha to grey out unconnected nodes
  g$alpha <- 1
  if (connected == "Hide") {
    g <- g |>
      dplyr::filter(degree >= 1)
  } else if (connected == "Grey out") {
    g <- g |>
      dplyr::mutate(
        alpha = ifelse(degree >= 1, 1, 0.1)
      )
  }
  if (!methods::is(g[[shape_col]], "character")) {
    shape_col <- ""
  }
  if (fill_col == "none") {
    fill_col <- ""
  }
  if (shape_col == "none") {
    shape_col <- ""
  }
  if (edge_col == "none") {
    edge_col <- ""
  }
  fill_sym <- rlang::sym(fill_col)
  shape_sym <- rlang::sym(shape_col)
  edge_sym <- rlang::sym(edge_col)
  if (node_alpha_col != "none") {
    g <- g |>
      dplyr::mutate(
        alpha = transform_alpha(.data[[node_alpha_col]], a = 0.1)
      )
  }
  p <- g |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = x,
        y = y,
        xend = xend,
        yend = yend
      )
    ) +
    ggnetwork::theme_blank() +
    ggnetwork::geom_edges(
      ggplot2::aes(
        col = {{ edge_sym }},
        linewidth = {{ edge_sym }}
      ),
      show.legend = edge_legend
      # show.legend = FALSE
    ) +
    ggplot2::scale_linewidth_continuous(
      range = c(0.5, 2),
      transform = edge_trans
    ) +
    ggplot2::scale_color_gradient2(low = "grey90", high = "black") +
    ggplot2::scale_shape_manual(
      values = rep(21:25, 1e4)
    ) +
    ggplot2::scale_alpha_identity() +
    ggnetwork::geom_nodes(
      ggplot2::aes(shape = {{ shape_sym }}),
      fill = "white",
      size = node_size
    ) +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        fill = {{ fill_sym }},
        shape = {{ shape_sym }},
        alpha = alpha
      ),
      size = node_size,
    ) +
    ggnetwork::geom_nodetext(
      ggplot2::aes(label = name),
      size = text_size,
      col = text_col
    ) +
    ggplot2::coord_equal() +
    ggplot2::guides(
      col = "none",
      alpha = "none",
      fill = ggplot2::guide_legend(override.aes = list(linetype = NA))
    )
  if (fill_col != "") {
    if (methods::is(g[[fill_col]], "character")) {
      p <- p + harrypotter::scale_fill_hp_d("Ravenclaw")
    } else {
      p <- p + harrypotter::scale_fill_hp("Ravenclaw")
    }
  }
  p
}
# pacman::p_load(tidyverse, ggnetwork, igraph)
# set.seed(2025)

# plot_network(
#   example_network,
#   fill_col = "site",
#   edge_col = "wij"
# ) |>
#   print()
