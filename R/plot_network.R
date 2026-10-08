utils::globalVariables(c(".data", "x", "y", "xend", "yend"))

# HELPERS ----

is_none <- function(x) is.null(x) || x %in% c("", "none")

check_columns <- function(df, cols) {
  cols <- cols[!vapply(cols, is_none, logical(1))]
  missing_cols <- setdiff(cols, names(df))
  if (length(missing_cols) > 0) {
    stop(
      "Attribute(s) not found in network: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
}

#' Plot a network
#'
#' @param g An igraph network.
#' @param seed Random seed used for the node layout.
#' @param connected How to treat unconnected (isolated) nodes: "Show" leaves
#'   them as they are, "Hide" removes them from the plot, and "Grey out"
#'   draws them (and their labels) with an alpha of 0.1. The layout is always
#'   computed on the full network, so the other nodes don't move.
#' @param lat,long Vertex attributes holding latitude and longitude. Supply
#'   both to use a geographic layout, or neither for a force-directed layout.
#' @param edge Edge attribute mapped to line width (numeric) or line type
#'   (anything else).
#' @param edge_legend Show the edge legend?
#' @param edge_trans Transformation applied to a numeric `edge` mapping.
#' @param label Vertex attribute used for node labels.
#' @param label_filter Vertex attribute that `label_inc` / `label_exc` are
#'   matched against. Defaults to `label`.
#' @param label_size Label text size.
#' @param label_inc Regular expression; only labels matching it are shown.
#' @param label_exc Regular expression; labels matching it are hidden.
#' @param label_col Colour of label
#' @param fill Vertex attribute mapped to node fill.
#' @param shape Vertex attribute mapped to node shape.
#' @param size Vertex attribute mapped to node size.
#' @param node_size Base node size.
#' @param node_centrality Vertex attribute mapped to node transparency.
#'   (Not yet implemented.)
#' @param pal Colour palette name.
#'
#' @return A ggplot object.
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
  label_col = "black",
  fill = "none",
  shape = "none",
  size = "none",
  node_size = 5,
  node_centrality = "none",
  pal = "ravenclaw"
) {
  set.seed(seed)
  connected <- match.arg(connected, c("Show", "Hide", "Grey out"))

  # CONNECTED ----
  # A node is unconnected if it has no edges to other nodes (self-loops
  # don't count).
  # They are tagged here and handled after the layout is computed, so the
  # remaining nodes keep the same positions whichever option is chosen.
  isolated <- igraph::degree(g, loops = FALSE) == 0
  if (connected == "Hide" && all(isolated)) {
    stop("No connected nodes left to plot after hiding.", call. = FALSE)
  }
  g <- igraph::set_vertex_attr(g, ".isolated", value = isolated)

  # LAYOUT ----
  if (is_none(lat) != is_none(long)) {
    stop("Supply both `lat` and `long`, or neither.", call. = FALSE)
  }

  if (is_none(lat)) {
    df <- ggnetwork::ggnetwork(g)
    coord_layer <- NULL
  } else {
    coords <- cbind(
      as.numeric(igraph::vertex_attr(g, long)),
      as.numeric(igraph::vertex_attr(g, lat))
    )
    if (anyNA(coords)) {
      stop("`lat`/`long` contain missing or non-numeric values.", call. = FALSE)
    }
    df <- ggnetwork::ggnetwork(g, layout = coords, scale = FALSE)
    coord_layer <- ggplot2::coord_quickmap()
  }

  check_columns(df, c(edge, label, label_filter, fill, shape, size))

  # Unconnected nodes only have node rows (no edge rows), so dropping rows
  # flagged `.isolated` removes them without moving anything else.
  if (connected == "Hide") {
    df <- df[!(df$.isolated %in% TRUE), , drop = FALSE]
  }

  # Per-node transparency: 0.1 for greyed-out nodes, otherwise opaque.
  df$.alpha <- if (connected == "Grey out") {
    ifelse(df$.isolated %in% TRUE, 0.1, 1)
  } else {
    1
  }

  # EDGES ----
  edge_layers <- if (is_none(edge)) {
    ggnetwork::geom_edges()
  } else if (is.numeric(df[[edge]])) {
    no_line <- ggplot2::guide_legend(override.aes = list(linetype = NA))
    list(
      ggnetwork::geom_edges(
        ggplot2::aes(linewidth = .data[[edge]]),
        show.legend = edge_legend
      ),
      ggplot2::scale_linewidth_continuous(
        range = c(0.5, 2),
        transform = edge_trans
      ),
      ggplot2::guides(fill = no_line, shape = no_line)
    )
  } else {
    ggnetwork::geom_edges(
      ggplot2::aes(linetype = .data[[edge]]),
      show.legend = edge_legend
    )
  }

  # NODES ----
  # Mapped aesthetics go in `node_aes`; fixed values go in `node_params`.
  node_aes <- list(alpha = rlang::sym(".alpha"))
  node_params <- list()
  node_scales <- list()

  if (is_none(fill)) {
    node_params$fill <- "white"
  } else {
    node_aes$fill <- rlang::sym(fill)
    node_scales$fill <- if (is.numeric(df[[fill]])) {
      fill_continuous(pal = pal)
    } else {
      fill_discrete(pal = pal)
    }
  }

  if (is_none(shape)) {
    node_params$shape <- 21
  } else {
    node_aes$shape <- rlang::sym(shape)
    n_shapes <- length(unique(stats::na.omit(df[[shape]])))
    node_scales$shape <- ggplot2::scale_shape_manual(
      values = rep_len(21:25, n_shapes)
    )
  }

  if (is_none(size)) {
    node_params$size <- node_size
  } else {
    node_aes$size <- rlang::sym(size)
    node_scales$size <- ggplot2::scale_size_continuous(
      range = c(node_size / 2, node_size * 2)
    )
  }

  node_scales$alpha <- ggplot2::scale_alpha_identity()

  node_layer <- rlang::exec(
    ggnetwork::geom_nodes,
    ggplot2::aes(!!!node_aes),
    !!!node_params
  )

  # LABELS ----
  label_layer <- NULL
  if (!is_none(label)) {
    labels <- df[[label]]
    filter_on <- if (is_none(label_filter)) labels else df[[label_filter]]
    if (!is_none(label_inc)) {
      keep <- stringr::str_detect(filter_on, convert_pipe(label_inc))
      labels[!keep %in% TRUE] <- NA
    }
    if (!is_none(label_exc)) {
      drop <- stringr::str_detect(filter_on, convert_pipe(label_exc))
      labels[drop %in% TRUE] <- NA
    }
    df$.label <- labels
    label_layer <- ggnetwork::geom_nodetext(
      ggplot2::aes(label = .data$.label, alpha = .data$.alpha),
      colour = label_col,
      size = label_size,
      na.rm = TRUE
    )
  }

  # PLOT ----
  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, xend = xend, yend = yend)) +
    edge_layers +
    node_layer +
    node_scales +
    label_layer +
    coord_layer +
    ggnetwork::theme_blank() +
    ggplot2::guides(size = "none")
}

# Quick manual test when the file is sourced directly
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  plot_network(
    example_network_2,
    fill = "site",
    label = "name",
    connected = "Grey out",
    node_size = 10,
    label_col = "white",
    lat = "Latitude",
    long = "Longitude"
  ) |>
    print()
}
