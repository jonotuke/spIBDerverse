utils::globalVariables(
  c(".data", "x", "y", "xend", "yend", ".isolated")
)

# HELPERS ----

is_none <- function(x) is.null(x) || x %in% c("", "none")

check_columns <- function(df, cols) {
  cols <- purrr::discard(cols, is_none)
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
#' @param outline_col Vertex attribute mapped to node outline colour
#' @param node_size Base node size.
#' @param alpha Vertex attribute to use for mapping for node alpha
#' @param fill_pal Fill palette name.
#' @param col_pal Colour palette name.
#' @param outline_width width of node outline
#' @param legend_size Fixed size of the node symbols in the legend keys,
#'   regardless of `node_size` or any `size` mapping.
#' @param legend_stroke Fixed outline width of the node symbols in the legend
#'   keys, regardless of `outline_width`.
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
  outline_col = "none",
  alpha = "none",
  node_size = 5,
  fill_pal = "ravenclaw",
  col_pal = "default",
  outline_width = 1,
  legend_size = 4,
  legend_stroke = 1
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

  check_columns(
    df,
    c(edge, label, label_filter, fill, shape, size, outline_col)
  )

  # Unconnected nodes only have node rows (no edge rows), so dropping rows
  # flagged `.isolated` removes them without moving anything else.
  if (connected == "Hide") {
    df <- df |> dplyr::filter(.isolated != TRUE)
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
    list(
      ggnetwork::geom_edges(
        ggplot2::aes(linewidth = .data[[edge]]),
        show.legend = edge_legend
      ),
      ggplot2::scale_linewidth_continuous(
        range = c(0.5, 2),
        transform = edge_trans
      )
    )
  } else {
    ggnetwork::geom_edges(
      ggplot2::aes(linetype = .data[[edge]]),
      show.legend = edge_legend
    )
  }

  # NODES ----
  # Mapped aesthetics go in `node_aes`; fixed values go in `node_params`.
  node_aes <- list()
  node_params <- list(stroke = outline_width)
  node_scales <- list()

  if (is_none(fill)) {
    node_params$fill <- "white"
  } else {
    node_aes$fill <- rlang::sym(fill)
    node_scales$fill <- if (is.numeric(df[[fill]])) {
      fill_continuous(pal = fill_pal)
    } else {
      fill_discrete(pal = fill_pal)
    }
  }

  if (is_none(outline_col)) {
    node_params$colour <- "black"
  } else {
    node_aes$colour <- rlang::sym(outline_col)
    node_scales$colour <- if (is.numeric(df[[outline_col]])) {
      colour_continuous(pal = col_pal)
    } else {
      colour_discrete(pal = col_pal)
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

  if (is_none(alpha)) {
    node_aes$alpha <- rlang::sym(".alpha")
    node_scales$alpha <- ggplot2::scale_alpha_identity()
  } else {
    node_aes$alpha <- rlang::sym(alpha)
  }

  node_layer <- rlang::exec(
    ggnetwork::geom_nodes,
    ggplot2::aes(!!!node_aes),
    !!!node_params
  )

  # Opaque underlay drawn between the edges and the nodes, so edges don't
  # show through semi-transparent nodes. It copies the node size, shape and
  # stroke (mapped or fixed) but is solid white with no legend.
  underlay_aes <- node_aes[intersect(names(node_aes), c("size", "shape"))]
  underlay_params <- node_params[
    intersect(names(node_params), c("size", "shape", "stroke"))
  ]
  underlay_params$fill <- "white"
  underlay_params$colour <- "white"
  underlay_params$alpha <- 1
  underlay_layer <- rlang::exec(
    ggnetwork::geom_nodes,
    ggplot2::aes(!!!underlay_aes),
    !!!underlay_params,
    show.legend = FALSE
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

  # LEGEND KEYS ----
  # Force every node legend key to the same size and stroke, whatever the
  # plot itself uses. alpha = 1 stops greyed-out nodes fading the keys, and
  # linetype = NA hides the edge line that `show.legend = TRUE` on the edge
  # layer would otherwise draw through each key.
  key_aes <- list(size = legend_size, stroke = legend_stroke, alpha = 1)
  if (!is_none(edge) && isTRUE(edge_legend)) {
    key_aes$linetype <- NA
  }
  key_guide <- ggplot2::guide_legend(override.aes = key_aes)

  # Only discrete scales get point keys; continuous fill/colour use a
  # colourbar, which has no points to resize.
  legend_guides <- list(size = "none")
  if (!is_none(fill) && !is.numeric(df[[fill]])) {
    legend_guides$fill <- key_guide
  }
  if (!is_none(outline_col) && !is.numeric(df[[outline_col]])) {
    legend_guides$colour <- key_guide
  }
  if (!is_none(shape)) {
    legend_guides$shape <- key_guide
  }

  # PLOT ----
  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, xend = xend, yend = yend)) +
    edge_layers +
    underlay_layer +
    node_layer +
    node_scales +
    label_layer +
    coord_layer +
    ggnetwork::theme_blank() +
    rlang::exec(ggplot2::guides, !!!legend_guides)
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  plot_network(
    example_network_2,
    fill = "Province",
    connected = "Grey out",
    node_size = 2,
    alpha = ".degree"
  ) |>
    print()
}
