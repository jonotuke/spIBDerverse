#' plot static map
#'
#' @param network_sf a network sf object
#' @param zoom level of tile resolution
#' @param maptype type of tile
#' @param key API key for stadia
#' @param fill_col node attribute for fill
#' @param shape_col node attribute for shape
#' @param edge_col edge attribute for edge width and colour
#' @param lon_range lon range to zoom
#' @param lat_range lat range to zoom
#' @param theme type of ggplot
#' @param pt_size node size
#'
#' @returns plot of network with background tiles
#'
#' @export
plot_static_map <- function(
  network_sf,
  zoom = NULL,
  maptype = "stamen_terrain",
  key = NULL,
  fill_col = "",
  shape_col = "",
  edge_col = "",
  lon_range = NULL,
  lat_range = NULL,
  theme = "minimal",
  pt_size = 3
) {
  if (is.null(key)) {
    message(
      "You need a stadia map key to use this\n See https://stadiamaps.com"
    )
  }
  # Register stadia maps key
  ggmap::register_stadiamaps(
    key = key
  )
  ggplot2::update_geom_defaults(
    "point",
    list(shape = 21, fill = "white")
  )
  # Get node SF
  nodes_sf <- network_sf$nodes_sf
  nodes_sf
  # Get edge SF
  edges_sf <- network_sf$edges_sf
  edges_sf
  # Get bounding box
  if (is.null(lat_range) | is.null(lon_range)) {
    bb <- sf::st_bbox(nodes_sf)
    names(bb) <- c("left", "bottom", "right", "top")
  } else {
    bb <- c(
      left = lon_range[1],
      bottom = lat_range[1],
      right = lon_range[2],
      top = lat_range[2]
    )
  }
  # Get zoom
  if (is.null(zoom)) {
    zoom <- ggmap::calc_zoom(bb)
  }
  # Get stadia tile
  tile <- ggmap::get_stadiamap(
    bb,
    zoom = zoom,
    maptype = maptype
  )
  # Fill colour
  if (fill_col == "none") {
    fill_col = ""
  }
  fill_col <- rlang::sym(fill_col)
  # Shape
  if (shape_col == "none") {
    shape_col = ""
  }
  if (!methods::is(nodes_sf[[shape_col]], "character")) {
    shape_col <- ""
  }
  shape_col <- rlang::sym(shape_col)
  # Edge
  if (edge_col == "none") {
    edge_col = ""
  }
  edge_sym <- rlang::sym(edge_col)
  p <- ggmap::ggmap(tile) +
    ggplot2::geom_sf(
      data = edges_sf,
      inherit.aes = FALSE,
      alpha = 0.2,
      ggplot2::aes(
        linewidth = {{ edge_sym }},
        col = {{ edge_sym }}
      ),
      show.legend = FALSE
    ) +
    ggplot2::geom_sf(
      data = nodes_sf,
      inherit.aes = FALSE,
      size = pt_size,
      ggplot2::aes(
        fill = {{ fill_col }},
        shape = {{ shape_col }}
      )
    ) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::labs(x = "Longitude", y = "Latitude") +
    ggplot2::scale_shape_manual(
      values = rep(21:25, 1e4)
    ) +
    ggplot2::scale_linewidth_continuous(
      range = c(0.5, 2)
    ) +
    ggplot2::coord_sf(expand = c(0, 0))
  # ggplot2::scale_color_gradient2(low = "grey10", high = "black")
  if (!is.null(lon_range)) {
    p <- p +
      ggplot2::scale_x_continuous(labels = identity)
  }
  if (!is.null(lat_range)) {
    p <- p + ggplot2::scale_y_continuous(labels = identity)
  }
  selected_theme <- dplyr::case_when(
    theme == "black white" ~ list(ggplot2::theme_bw()),
    theme == "void" ~ list(ggplot2::theme_void()),
    TRUE ~ list(ggplot2::theme_minimal())
  )[[1]]
  p <- p + selected_theme
  p
}
# pacman::p_load(conflicted, tidyverse, targets)
# jono_key <- "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"

# example_network_2 |>
#   convert_sf("Latitude", "Longitude") |>
#   add_convert_bb_adj() |>
#   plot_static_map(
#     zoom = 6,
#     key = jono_key,
#     edge_col = "wij"
#   ) |>
#   print()
