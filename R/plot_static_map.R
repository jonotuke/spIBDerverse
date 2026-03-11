plot_static_map <- function(
  network_sf,
  zoom = NULL,
  maptype = "stamen_terrain",
  key = NULL,
  fill_col = "",
  shape_col = "",
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
  bb <- sf::st_bbox(nodes_sf)
  names(bb) <- c("left", "bottom", "right", "top")
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
  p <- ggmap::ggmap(tile) +
    ggplot2::geom_sf(
      data = edges_sf,
      inherit.aes = FALSE,
      alpha = 0.2
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
    )
  if (!is.null(lon_range)) {
    p <- p + ggplot2::scale_x_continuous(limits = lon_range, labels = identity)
  }
  if (!is.null(lat_range)) {
    p <- p + ggplot2::scale_y_continuous(limits = lat_range, labels = identity)
  }
  selected_theme <- dplyr::case_when(
    theme == "black white" ~ list(theme_bw()),
    theme == "void" ~ list(theme_void()),
    TRUE ~ list(theme_minimal())
  )[[1]]
  p <- p + selected_theme
  p
}
# pacman::p_load(conflicted, tidyverse, targets)
# jono_key <- "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
# example_sf_adj <- add_convert_bb_adj(example_sf)
# example_sf_adj

# plot_static_map(
#   example_sf_adj,
#   zoom = 12,
#   key = jono_key,
#   fill_col = "genetic_sex",
#   shape_col = "site",
#   lon_range = c(138.55, 138.65),
#   lat_range = c(-34.86, -34.80),
#   theme = "void"
# ) |>
#   print()
