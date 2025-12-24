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
#' @param fill_col vertex attribute for node fill
#' @param shape_col vertex attribute for node shape
#' @param node_size node size
#' @param text_size label size
#' @param labels add labels
#' @param label_col vertex attribute to use for labels
#' @param label_inc regular expression to include labels
#' @param label_exc regular expression to exclude labels
#' @param connected choice for how to deal with isolated nodes
#'
#' @return ggnetwork plot
#' @export
#'
#' @examples
#' example_ggnet <- ggnetwork::ggnetwork(example_network)
#' plot_ggnet(example_ggnet)
plot_ggnet <- function(
  ggnet_obj,
  fill_col = "",
  shape_col = "",
  node_size = 4,
  text_size = 4,
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
  if (label_col != "") {
    label_col <- rlang::sym(label_col)
    ggnet_obj <-
      ggnet_obj |>
      dplyr::mutate(
        name = {{ label_col }}
      )
  }
  # Clean labels
  if (label_inc != "") {
    label_inc <- label_inc |>
      stringr::str_replace_all(",", "|") |>
      stringr::str_remove_all(" ")
    ggnet_obj <- ggnet_obj |>
      dplyr::mutate(
        name = dplyr::case_when(
          stringr::str_detect(name, label_inc) ~ name,
          TRUE ~ NA
        )
      )
  }
  if (label_exc != "") {
    label_exc <- label_exc |>
      stringr::str_replace_all(",", "|") |>
      stringr::str_remove_all(" ")
    ggnet_obj <- ggnet_obj |>
      dplyr::mutate(
        name = dplyr::case_when(
          stringr::str_detect(name, label_exc) ~ NA,
          TRUE ~ name
        )
      )
  }
  if (!labels) {
    ggnet_obj$name <- NA
  }
  alpha <- 1
  if (connected == "Hide") {
    ggnet_obj <- ggnet_obj |>
      dplyr::filter(degree >= 1)
  } else if (connected == "Grey out") {
    alpha <- ifelse(ggnet_obj$degree >= 1, 1, 0.1)
  }

  # Set up fill and shape columns
  fill_col <- rlang::sym(fill_col)
  shape_col <- rlang::sym(shape_col)
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
    ggnetwork::geom_edges(
      show.legend = FALSE
    ) +
    ggplot2::scale_linewidth_continuous(
      range = c(0.5, 2)
    ) +
    ggplot2::scale_shape_manual(
      values = rep(21:25, 1e4)
    ) +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        fill = {{ fill_col }},
        shape = {{ shape_col }},
      ),
      size = node_size,
      alpha = alpha
    ) +
    ggnetwork::geom_nodetext(
      ggplot2::aes(label = name),
      size = text_size
    ) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::coord_equal()
  p
}
# pacman::p_load(tidyverse, ggnetwork, igraph)
# set.seed(2025)
# example_network |>
#   ggnetwork() |>
#   plot_ggnet(
#     labels = TRUE,
#     node_size = 10,
#     text_size = 8,
#     label_exc = "1,3, 4"
#   ) |>
#   print()
