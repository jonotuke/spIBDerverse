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
    "name"
  )
)
#' plot ggnet
#'
#' @param ggnet_obj ggnetwork dataframe
#' @param fill vertex attribute for node fill
#' @param shape vertex attribute for node shape
#' @param node_size node size
#' @param text_size label size
#' @param labels add labels
#' @param label_inc regular expression to include labels
#' @param label_exc regular expression to exclude labels
#' @param connected boolean to include isolated nodes
#'
#' @return ggnetwork plot
#' @export
#'
#' @examples
#' example_ggnet <- ggnetwork::ggnetwork(example_network)
#' plot_ggnet(example_ggnet)
plot_ggnet <- function(
  ggnet_obj,
  fill = "none",
  shape = "none",
  node_size = 4,
  text_size = 4,
  labels = FALSE,
  label_inc = "",
  label_exc = "",
  connected = TRUE
) {
  ggnet_obj <- ggnet_obj |>
    dplyr::mutate(
      fill_col = "default",
      shape_col = "default"
    )
  if (fill != "none") {
    ggnet_obj <- ggnet_obj |>
      dplyr::mutate(fill_col = .data[[fill]])
  }
  if (shape != "none") {
    ggnet_obj <- ggnet_obj |>
      dplyr::mutate(shape_col = .data[[shape]])
  }
  if (label_inc != "") {
    ggnet_obj <- ggnet_obj |>
      dplyr::mutate(
        name = dplyr::case_when(
          stringr::str_detect(name, label_inc) ~ name,
          TRUE ~ NA
        )
      )
  }
  if (label_exc != "") {
    ggnet_obj <- ggnet_obj |>
      dplyr::mutate(
        name = dplyr::case_when(
          str_detect(name, label_exc) ~ NA,
          TRUE ~ name
        )
      )
  }
  if (connected) {
    ggnet_obj <- ggnet_obj |>
      dplyr::filter(degree >= 1)
  }
  p <- ggnet_obj |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = x,
        y = y,
        xend = xend,
        yend = yend,
        linewidth = wij,
      )
    ) +
    ggnetwork::theme_blank() +
    ggnetwork::geom_edges(show.legend = FALSE) +
    ggplot2::scale_linewidth_continuous(range = c(0.5, 2)) +
    ggplot2::scale_shape_manual(
      values = rep(21:25, 1e4)
    ) +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        fill = fill_col,
        shape = shape_col
      ),
      size = node_size
    ) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::labs(
      fill = fill,
      shape = shape
    ) +
    ggplot2::guides(
      fill = ggplot2::guide_legend(override.aes = list(shape = 21))
    ) +
    ggplot2::coord_equal()
  if (fill == "none") {
    p <- p +
      ggplot2::guides(
        fill = "none"
      ) +
      ggplot2::scale_fill_manual(values = "white")
  }
  if (shape == "none") {
    p <- p +
      ggplot2::guides(
        shape = "none"
      ) +
      ggplot2::scale_shape_manual(values = 21)
  }
  if (labels) {
    p <- p +
      ggnetwork::geom_nodetext(
        ggplot2::aes(label = name),
        size = text_size
      )
  }
  p
}
# pacman::p_load(tidyverse, ggnetwork, igraph)
# example_network
# example_network |>
#   ggnetwork() |>
#   plot_ggnet(
#     labels = TRUE,
#     fill = "site",
#     node_size = 10
#   ) |>
#   print()
