get_sym <- function(x) {
  if (x == "none") {
    x <- ""
  }
  rlang::sym(x)
}
utils::globalVariables(
  c(
    "label_colour",
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
#' plot network
#'
#' @param g network
#' @param seed seed to set node locations
#' @param connected choice for how to deal with isolated nodes with choices
#' Hide, Show, Grey out
#' @param edge edge attribute for line colour
#' @param edge_legend boolean to control edge legend
#' @param edge_trans transformation for edge mapping
#' @param label vertex attribute to use for labels
#' @param label_size label size
#' @param label_inc regular expression to include labels
#' @param label_exc regular expression to exclude labels
#' @param fill vertex attribute for node fill
#' @param shape vertex attribute for node shape
#' @param node_size node size
#' @param node_centrality vertext attribute for node alpha
#'
#' @return network plot
#' @export
#'
#' @examples
#' plot_network(example_network)
plot_network <- function(
  g,
  seed = 2026,
  connected = "Show",
  edge = "none",
  edge_legend = TRUE,
  edge_trans = "identity",
  label = "none",
  label_size = 4,
  label_inc = "",
  label_exc = "",
  fill = "none",
  shape = "none",
  node_size = 5,
  node_centrality = "none"
) {
  # SETUP ----
  ggplot2::update_geom_defaults(
    "point",
    list(shape = 21, fill = "white")
  )
  set.seed(seed)
  g <- ggnetwork::ggnetwork(g)
  # LABEL COLUMN----
  g$label <- NA
  if (!label %in% c("", "none")) {
    label_sym <- get_sym(label)
    g <- g |>
      dplyr::mutate(label = {{ label_sym }})
    if (label_inc != "") {
      label_inc <- convert_pipe(label_inc)
      g <- g |>
        dplyr::mutate(
          label = dplyr::case_when(
            stringr::str_detect(label, label_inc) ~ name,
            TRUE ~ NA
          )
        )
    }
    if (label_exc != "") {
      label_exc <- convert_pipe(label_exc)
      g <- g |>
        dplyr::mutate(
          label = dplyr::case_when(
            stringr::str_detect(label, label_exc) ~ NA,
            TRUE ~ label
          )
        )
    }
  }
  if (fill %in% c("", "none")) {
    g$label_colour <- "black"
  } else {
    g$label_colour <- get_text_font(g[[fill]], type = "text")
  }
  # NODE ALPHA ----
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
  if (node_centrality != "none") {
    g <- g |>
      dplyr::mutate(
        alpha = transform_alpha(
          .data[[node_centrality]],
          a = 0.1
        )
      )
  }
  # BASE PLOT ----
  p <- g |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = x,
        y = y,
        xend = xend,
        yend = yend
      )
    )
  # EDGES ----
  if (edge %in% c("", "none")) {
    p <- p + ggnetwork::geom_edges()
  } else {
    if (is.character(g[[edge]])) {
      p <- p +
        ggnetwork::geom_edges(
          ggplot2::aes(
            linetype = .data[[edge]]
          ),
          show.legend = edge_legend
        )
    } else {
      p <- p +
        ggnetwork::geom_edges(
          ggplot2::aes(
            colour = .data[[edge]],
            linewidth = .data[[edge]]
          ),
          show.legend = edge_legend
        ) +
        ggplot2::scale_linewidth_continuous(
          range = c(0.5, 2),
          transform = edge_trans
        ) +
        ggplot2::scale_color_gradient2(
          low = "grey90",
          high = "black"
        ) +
        ggplot2::guides(
          colour = "none",
          fill = ggplot2::guide_legend(
            override.aes = list(linetype = NA)
          ),
          shape = ggplot2::guide_legend(
            override.aes = list(linetype = NA)
          )
        )
    }
  }
  # NODES ----
  fill_sym <- get_sym(fill)
  shape_sym <- get_sym(shape)
  p <- p +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        shape = {{ shape_sym }}
      ),
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
    ggplot2::scale_alpha_identity() +
    ggplot2::scale_shape_manual(
      values = rep(21:25, 1e4)
    )
  if (methods::is(g[[fill]], "character")) {
    p <- p + harrypotter::scale_fill_hp_d("Ravenclaw")
  } else {
    p <- p + harrypotter::scale_fill_hp("Ravenclaw")
  }
  # LABELS ----
  p <- p + ggnewscale::new_scale_colour()
  p <- p +
    ggnetwork::geom_nodetext(
      ggplot2::aes(
        label = label,
        colour = label_colour
      ),
      size = label_size,
      show.legend = FALSE
    ) +
    ggplot2::scale_colour_identity()
  # EXTRAS ----
  p <- p +
    ggnetwork::theme_blank() +
    ggplot2::guides(
      colour = "none",
      alpha = "none"
    )
  return(p)
}
# pacman::p_load(conflicted, tidyverse, targets)
# plot_network_2(
#   example_network,
#   label = "name",
#   fill = "site",
#   shape = "genetic_sex",
#   edge = "wij",
#   node_size = 10
# ) |>
#   print()
