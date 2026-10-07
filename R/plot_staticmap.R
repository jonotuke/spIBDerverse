#' Plot a network on a static Stadia map
#'
#' Draws the network with [plot_network()] using a geographic layout, then
#' places a Stadia map tile underneath it. All styling (edges, nodes, labels,
#' palettes, ...) is handled by `plot_network()`, so any changes made there
#' carry through automatically.
#'
#' @param g An igraph network.
#' @param key Stadia API key. See <https://stadiamaps.com>.
#' @param lat,long Vertex attributes holding latitude and longitude.
#' @param zoom Stadia tile zoom.
#' @param maptype Stadia map tile type.
#' @param lon_range,lat_range Optional length-2 vectors. If both are supplied,
#'   the network is filtered to nodes inside this box and the map is cropped
#'   to it.
#' @param pad Fraction of the node extent added around the edges of the map
#'   when `lon_range`/`lat_range` are not supplied.
#' @param theme Plot theme: "minimal", "black white", "void", or "blank"
#'   (keeps the theme from `plot_network()`).
#' @param ... Further arguments passed to [plot_network()], e.g. `fill`,
#'   `shape`, `edge`, `label`, `node_size`, `pal`.
#'
#' @return A ggplot object, or `NULL` (invisibly) if no key is given.
#' @export
#'
#' @examples
#' \dontrun{
#' plot_staticmap(example_network, key = my_key, zoom = 11, fill = "site")
#' }
plot_staticmap <- function(
  g,
  key = NULL,
  lat = "lat",
  long = "long",
  zoom = 5,
  maptype = "stamen_terrain",
  lon_range = NULL,
  lat_range = NULL,
  pad = 0.05,
  theme = "minimal",
  ...
) {
  # KEY ----
  if (is.null(key)) {
    message("You need a stadia map key to use this. See https://stadiamaps.com")
    return(invisible(NULL))
  }

  # COORDINATES ----
  # check_columns(
  #   stats::setNames(nm = igraph::vertex_attr_names(g)),
  #   c(long, lat)
  # )
  get_coords <- function(g) {
    list(
      lon = as.numeric(igraph::vertex_attr(g, long)),
      lat = as.numeric(igraph::vertex_attr(g, lat))
    )
  }
  xy <- get_coords(g)

  # FILTER ----
  use_ranges <- !is.null(lat_range) && !is.null(lon_range)
  if (use_ranges) {
    keep <- xy$lon >= min(lon_range) &
      xy$lon <= max(lon_range) &
      xy$lat >= min(lat_range) &
      xy$lat <= max(lat_range)
    g <- igraph::induced_subgraph(g, which(keep %in% TRUE))
    if (igraph::vcount(g) == 0) {
      stop("No nodes fall inside `lon_range` / `lat_range`.", call. = FALSE)
    }
    xy <- get_coords(g)
  }

  # BOUNDING BOX ----
  if (use_ranges) {
    BB <- c(
      left = min(lon_range),
      bottom = min(lat_range),
      right = max(lon_range),
      top = max(lat_range)
    )
  } else {
    pad_range <- function(r) {
      d <- diff(r)
      if (d == 0) {
        d <- 0.02
      } # single point / all nodes in one spot
      r + c(-1, 1) * d * pad
    }
    lon_r <- pad_range(range(xy$lon, na.rm = TRUE))
    lat_r <- pad_range(range(xy$lat, na.rm = TRUE))
    BB <- c(
      left = lon_r[1],
      bottom = lat_r[1],
      right = lon_r[2],
      top = lat_r[2]
    )
  }

  # TILES ----
  ggmap::register_stadiamaps(key = key, write = FALSE)
  tile <- ggmap::get_stadiamap(BB, zoom = zoom, maptype = maptype)

  # NETWORK ----
  p <- plot_network(g, lat = lat, long = long, ...)

  # Put the map underneath every layer plot_network() created
  p$layers <- c(list(ggmap::inset_ggmap(tile)), p$layers)

  # Crop to the bounding box (replaces plot_network's coord_quickmap)
  p <- suppressMessages(
    p +
      ggplot2::coord_quickmap(
        xlim = unname(BB[c("left", "right")]),
        ylim = unname(BB[c("bottom", "top")]),
        expand = FALSE
      )
  )

  # EXTRAS ----
  if (theme != "blank") {
    p <- p +
      switch(
        theme,
        "black white" = ggplot2::theme_bw(),
        "void" = ggplot2::theme_void(),
        ggplot2::theme_minimal()
      ) +
      ggplot2::labs(x = "Longitude", y = "Latitude")
  }

  p
}

if (sys.nframe() == 5) {
  my_key <- "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
  plot_staticmap(
    example_network,
    key = my_key,
    lat = "lat",
    long = "long",
    zoom = 11,
    fill = "site",
    edge = "edge_type",
    edge_trans = "log10",
    label = "site"
  ) |>
    print()
}
