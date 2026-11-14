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
#' List available palettes
#'
#' Finds every `scale_fill_*()` function exported by the installed version of
#' ggsci, so the list stays current when ggsci is updated. Also includes
#' `"default"`, which gives ggplot2's own default scale and works for both
#' discrete and continuous data.
#'
#' @returns a data frame with the palette name (the value to pass as `pal`),
#'   whether it is discrete, continuous or both
get_palettes <- function() {
  pals <- getNamespaceExports("ggsci")
  pals <- tibble::tibble(name = pals)
  pals <- pals |>
    dplyr::filter(
      stringr::str_detect(
        name,
        "^scale_fill"
      )
    )
  pals <- pals |>
    dplyr::mutate(
      name = stringr::str_remove_all(name, "scale_fill_"),
    ) |>
    dplyr::distinct(name)
  pals <- pals |>
    dplyr::mutate(
      type = ifelse(
        name %in% c("gsea", "material", "bs5", "tw3"),
        "continuous",
        "discrete"
      )
    )
  pals <- dplyr::bind_rows(
    tibble::tibble(name = "default", type = "both"),
    pals
  )
  pals
}

#' Build a palette scale by name
#'
#' Internal helper that looks up `scale_<aesthetic>_<pal>()` in ggsci and
#' calls it, so any palette in your installed version of ggsci can be used.
#' Use `pal = "default"` to get ggplot2's default discrete or continuous
#' scale instead.
#'
#' @param aesthetic "fill" or "colour"/"color"
#' @param pal ggsci palette name, e.g. "npg", "lancet", "gsea", or "default"
#'   for the ggplot2 default
#' @param type "discrete" or "continuous". For ggsci palettes this is used for
#'   validation only; for `pal = "default"` it picks which ggplot2 scale to use.
#' @param ... passed on to the scale (e.g. `palette = "category20"`,
#'   `alpha = 0.8`, `reverse = TRUE` for ggsci; any ggplot2 scale argument
#'   such as `name` or `limits` for the default)
#'
#' @returns a ggplot2 scale
pal_scale <- function(aesthetic, pal, type = "discrete", ...) {
  type <- match.arg(type, c("discrete", "continuous"))

  if (pal == "default") {
    fn_name <- paste0("scale_", aesthetic, "_", type)
    if (!exists(fn_name, envir = asNamespace("ggplot2"), inherits = FALSE)) {
      stop(
        stringr::str_glue("{fn_name} is not in ggplot2; check `aesthetic`")
      )
    }
    return(getExportedValue("ggplot2", fn_name)(...))
  }

  pals <- get_palettes()
  pal_type <- pals |>
    dplyr::filter(name == pal) |>
    dplyr::pull(type)
  if (length(pal_type) == 0) {
    stop(
      stringr::str_glue("{pal} is not in ggsci package")
    )
  }
  if (pal_type != type) {
    stop(
      "Wrong palette type"
    )
  }

  fn_name <- paste0("scale_", aesthetic, "_", pal)
  if (!exists(fn_name, envir = asNamespace("ggsci"), inherits = FALSE)) {
    stop(
      "That palette is not in ggsci"
    )
  }
  getExportedValue("ggsci", fn_name)(...)
}
#' converts NA to unknown
#'
#' @param g igraph object
#' @param name node attribute to convert
#'
#' @returns updated igraph object
#'
#' @export
#' @examples
#' convert_na_unknown(example_network_3, "site")
convert_na_unknown <- function(g, name) {
  names <- get_node_attributes(g)
  if (!name %in% names) {
    stop(
      stringr::str_glue("{name} is not a node attribute")
    )
  }
  x <- igraph::vertex_attr(g, name)
  if (!is.numeric(x)) {
    x[is.na(x)] <- "Unknown"
    g <- igraph::set_vertex_attr(g, name, value = x)
  }
  g
}
#' converts all NAs in node attributes
#'
#' @param g igraph object
#'
#' @returns igraph object with all NAs converted
#'
#' @export
#' @examples
#' convert_nas_unknown(example_network_3)
convert_nas_unknown <- function(g) {
  names <- get_node_attributes(g)
  for (i in names) {
    g <- convert_na_unknown(g, i)
  }
  g
}
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

# PLOT ----
#' Plot a network
#'
#' @param g An igraph network.
#' @param seed Random seed used for the node layout.
#' @param layout node layout
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
#' @param fill_label Title for the fill legend. Defaults to the name of the
#'   `fill` attribute. If `shape` or `outline_col` use the same attribute as
#'   `fill`, they get the same title so their legends stay merged.
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
#' @param convert_nas boolean to convert missing nodes attr from NA to unknown
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
  layout = "nicely",
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
  fill_label = NULL,
  shape = "none",
  size = "none",
  outline_col = "none",
  alpha = "none",
  node_size = 5,
  fill_pal = "default",
  col_pal = "default",
  outline_width = 1,
  legend_size = 4,
  legend_stroke = 1,
  convert_nas = TRUE
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

  # MISSING ----
  if (convert_nas) {
    g <- convert_nas_unknown(g)
  }

  # LAYOUT ----
  if (is_none(lat) != is_none(long)) {
    stop("Supply both `lat` and `long`, or neither.", call. = FALSE)
  }

  if (is_none(lat)) {
    coords <- add_layout(g, name = layout)
    df <- ggnetwork::ggnetwork(g, layout = coords)
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
    c(edge, label, label_filter, fill, shape, size, outline_col, alpha)
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

  same_var <- function(a, b) !is_none(a) && !is_none(b) && identical(a, b)

  # Legend title for fill. waiver() keeps ggplot2's default (the attribute
  # name). Any other scale mapped to the same attribute gets the same title,
  # otherwise ggplot2 would split them into separate legends.
  fill_name <- if (is_none(fill_label)) ggplot2::waiver() else fill_label
  title_for <- function(var) {
    if (same_var(var, fill)) fill_name else ggplot2::waiver()
  }

  if (is_none(fill)) {
    node_params$fill <- "white"
  } else {
    node_aes$fill <- rlang::sym(fill)
    node_scales$fill <- if (is.numeric(df[[fill]])) {
      # if (fill_pal == "default") {
      #   fill_pal <- "gsea"
      # }
      pal_scale(
        aesthetic = "fill",
        pal = fill_pal,
        type = "continuous",
        name = fill_name
      )
    } else {
      # if (fill_pal == "default") {
      #   fill_pal <- "npg"
      # }
      pal_scale(
        aesthetic = "fill",
        pal = fill_pal,
        type = "discrete",
        name = fill_name
      )
    }
  }

  if (is_none(outline_col)) {
    node_params$colour <- "black"
  } else {
    node_aes$colour <- rlang::sym(outline_col)
    node_scales$colour <- if (is.numeric(df[[outline_col]])) {
      # if (col_pal == "default") {
      #   col_pal <- "gsea"
      # }
      pal_scale(
        aesthetic = "colour",
        pal = col_pal,
        type = "continuous",
        name = title_for(outline_col)
      )
    } else {
      # if (col_pal == "default") {
      #   col_pal <- "npg"
      # }
      pal_scale(
        aesthetic = "colour",
        pal = col_pal,
        type = "discrete",
        name = title_for(outline_col)
      )
    }
  }

  if (is_none(shape)) {
    node_params$shape <- 21
  } else {
    node_aes$shape <- rlang::sym(shape)
    n_shapes <- length(unique(stats::na.omit(df[[shape]])))
    node_scales$shape <- ggplot2::scale_shape_manual(
      values = rep_len(21:25, n_shapes),
      name = title_for(shape)
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
  key_aes <- list(
    size = legend_size,
    stroke = legend_stroke,
    alpha = 1
  )
  if (!is_none(edge) && isTRUE(edge_legend)) {
    key_aes$linetype <- NA
  }
  key_guide <- function(...) {
    ggplot2::guide_legend(override.aes = utils::modifyList(key_aes, list(...)))
  }

  fill_legend <- !is_none(fill) && !is.numeric(df[[fill]])
  colour_legend <- !is_none(outline_col) && !is.numeric(df[[outline_col]])

  legend_guides <- list(size = "none")
  if (fill_legend) {
    legend_guides$fill <- if (same_var(fill, shape)) {
      key_guide()
    } else {
      key_guide(shape = 21)
    }
  }
  if (colour_legend) {
    colour_over <- list()
    if (!same_var(outline_col, shape)) {
      colour_over$shape <- 21
    }
    if (!(fill_legend && same_var(outline_col, fill))) {
      colour_over$fill <- "white"
    }
    legend_guides$colour <- rlang::exec(key_guide, !!!colour_over)
  }
  if (!is_none(shape)) {
    legend_guides$shape <- if (fill_legend && same_var(shape, fill)) {
      key_guide()
    } else {
      key_guide(fill = "white")
    }
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
    example_network,
    fill = "site",
    fill_label = "BOB"
  ) |>
    print()
}
