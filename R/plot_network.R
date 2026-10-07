is_none <- function(x) x %in% c("", "none")

get_sym <- function(x) rlang::sym(if (is_none(x)) "" else x)

utils::globalVariables(c(".data", ".degree", "x", "y", "xend", "yend", "alpha"))

#' plot network
#'
#' @param g network
#' @param seed seed to set node locations
#' @param lat vertex attribute to use for latitude
#' @param long vertex attribute to use for longitude
#' @param connected choice for how to deal with isolated nodes with choices
#' Hide, Show, Grey out
#' @param edge edge attribute for line colour
#' @param edge_legend boolean to control edge legend
#' @param edge_trans transformation for edge mapping
#' @param label vertex attribute to use for labels
#' @param label_size label size
#' @param label_filter variable to filter on
#' @param label_inc regular expression to include labels
#' @param label_exc regular expression to exclude labels
#' @param fill vertex attribute for node fill
#' @param shape vertex attribute for node shape
#' @param size vertex attribute for node size
#' @param node_size node size
#' @param node_centrality vertex attribute for node alpha
#' @param pal colour palette
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
  lat = "none",
  long = "none",
  edge = "none",
  edge_legend = TRUE,
  edge_trans = "identity",
  label = "none",
  label_filter = "none",
  label_size = 4,
  label_inc = "",
  label_exc = "",
  fill = "none",
  shape = "none",
  size = "none",
  node_size = 5,
  node_centrality = "none",
  pal = "ravenclaw"
) {
  # SETUP ----
  ggplot2::update_geom_defaults(
    "point",
    list(shape = 21, fill = "white")
  )
  set.seed(seed)
  # LAYOUT ----
  if (is_none(lat) != is_none(long)) {
    stop("Supply both `lat` and `long`, or neither.", call. = FALSE)
  }
  if (is_none(lat)) {
    g <- ggnetwork::ggnetwork(g)
    coord_layer <- NULL
  } else {
    attrs <- igraph::vertex_attr_names(g)
    missing_attrs <- setdiff(c(long, lat), attrs)
    if (length(missing_attrs) > 0) {
      stop(
        "Vertex attribute(s) not found: ",
        paste(missing_attrs, collapse = ", "),
        call. = FALSE
      )
    }
    coords <- cbind(
      as.numeric(igraph::vertex_attr(g, long)),
      as.numeric(igraph::vertex_attr(g, lat))
    )
    if (anyNA(coords)) {
      stop("`lat`/`long` contain missing or non-numeric values.", call. = FALSE)
    }
    g <- ggnetwork::ggnetwork(g, layout = coords, scale = FALSE)
    coord_layer <- ggplot2::coord_quickmap()
  }

  # LABELS ----
  g$label <- NA
  if (!is_none(label)) {
    g$label <- g[[label]]
    if (is_none(label_filter)) {
      g$label_filter <- g$label
    } else {
      g$label_filter <- g[[label_filter]]
    }
    if (label_inc != "") {
      keep <- stringr::str_detect(g$label_filter, convert_pipe(label_inc))
      g$label <- dplyr::if_else(keep, g$label, NA)
    }
    if (label_exc != "") {
      drop <- stringr::str_detect(g$label_filter, convert_pipe(label_exc))
      g$label <- dplyr::if_else(drop, NA, g$label)
    }
  }

  # EDGES ----
  edge_layers <- if (is_none(edge)) {
    ggnetwork::geom_edges()
  } else if (is.character(g[[edge]])) {
    ggnetwork::geom_edges(
      ggplot2::aes(linetype = .data[[edge]]),
      show.legend = edge_legend
    )
  } else {
    no_line <- ggplot2::guide_legend(
      override.aes = list(linetype = NA)
    )
    list(
      ggnetwork::geom_edges(
        ggplot2::aes(linewidth = .data[[edge]]),
        show.legend = edge_legend
      ),
      ggplot2::scale_linewidth_continuous(
        range = c(0.5, 2),
        transform = edge_trans
      ),
      ggplot2::scale_colour_gradient2(low = "grey90", high = "black"),
      ggplot2::guides(
        fill = no_line,
        shape = no_line
      )
    )
  }

  # NODES ----
  fill_sym <- get_sym(fill)
  shape_sym <- get_sym(shape)
  fill_scale <- if (is.character(g[[fill]])) {
    fill_discrete(pal = pal)
  } else {
    fill_continuous(pal = pal)
  }
  size_sym <- if (is_none(size)) {
    node_size
  } else {
    rlang::sym(size)
  }
  size_scale <- if (is_none(size)) {
    ggplot2::scale_size_identity()
  } else {
    ggplot2::scale_size_continuous(range = c(node_size / 2, node_size * 2))
  }

  # PLOT ----
  ggplot2::ggplot(g, ggplot2::aes(x = x, y = y, xend = xend, yend = yend)) +
    edge_layers +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        shape = {{ shape_sym }},
        size = {{ size_sym }}
      ),
      fill = "white",
    ) +
    ggnetwork::geom_nodes(
      ggplot2::aes(
        fill = {{ fill_sym }},
        shape = {{ shape_sym }},
        size = {{ size_sym }}
      )
    ) +
    size_scale +
    ggplot2::scale_alpha_identity() +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_shape_manual(values = rep(21:25, 1e4)) +
    fill_scale +
    ggnetwork::geom_nodetext(
      ggplot2::aes(label = label),
      colour = "black",
      size = label_size
    ) +
    coord_layer +
    ggnetwork::theme_blank() +
    ggplot2::guides(
      colour = "none",
      alpha = "none",
      size = "none"
    )
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  plot_network(
    example_network,
    label = "name",
    fill = "site",
    size = ".closeness",
    node_size = 5,
    edge = "wij",
    edge_trans = "log10"
  ) |>
    print()
}
