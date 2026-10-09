# HELPERS ----

# Numeric longitude/latitude of every node.
get_node_coords <- function(g, lat = "lat", long = "long") {
  check_columns(
    stats::setNames(nm = igraph::vertex_attr_names(g)),
    c(long, lat)
  )
  list(
    lon = as.numeric(igraph::vertex_attr(g, long)),
    lat = as.numeric(igraph::vertex_attr(g, lat))
  )
}

# Widen a range by `pad` (a fraction of its width), optionally round it
# outwards to `digits` decimals, and clamp it to `limits`.
pad_range <- function(r, pad = 0.05, digits = NULL, limits = c(-Inf, Inf)) {
  d <- diff(r)
  r <- if (d == 0) {
    r + c(-0.01, 0.01) # single point / all nodes in one spot
  } else {
    r + c(-1, 1) * d * pad
  }
  if (!is.null(digits)) {
    m <- 10^digits
    r <- c(floor(r[1] * m), ceiling(r[2] * m)) / m
  }
  c(max(r[1], limits[1]), min(r[2], limits[2]))
}

#' Longitude and latitude extent of a network
#'
#' The box plot_staticmap() draws when no ranges are supplied. Used by the
#' Shiny module to fill in the range inputs.
#'
#' @inheritParams plot_staticmap
#' @param digits If not `NULL`, round the range outwards to this many
#'   decimals, so no node falls outside it.
#' @return A list with length-2 numeric vectors `lon` and `lat`.
#' @noRd
node_coord_range <- function(
  g,
  lat = "lat",
  long = "long",
  pad = 0.05,
  digits = NULL
) {
  xy <- get_node_coords(g, lat, long)
  if (all(is.na(xy$lon)) || all(is.na(xy$lat))) {
    stop("`lat`/`long` contain no numeric values.", call. = FALSE)
  }
  list(
    lon = pad_range(range(xy$lon, na.rm = TRUE), pad, digits, c(-180, 180)),
    lat = pad_range(range(xy$lat, na.rm = TRUE), pad, digits, c(-90, 90))
  )
}

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
#' @param jitter Maximum random shift (in degrees) applied to each node's
#'   position, so nodes in the same place don't overlap. Applied after
#'   filtering by `lon_range`/`lat_range`.
#' @param seed Random seed used for the jitter (and passed to
#'   [plot_network()]).
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
  jitter = 0,
  seed = 2026,
  theme = "minimal",
  ...
) {
  # KEY ----
  if (is_none(key)) {
    message("You need a stadia map key to use this. See https://stadiamaps.com")
    return(invisible(NULL))
  }

  # FILTER ----
  use_ranges <- !is.null(lat_range) && !is.null(lon_range)
  if (use_ranges) {
    xy <- get_node_coords(g, lat, long)
    keep <- xy$lon >= min(lon_range) &
      xy$lon <= max(lon_range) &
      xy$lat >= min(lat_range) &
      xy$lat <= max(lat_range)
    g <- igraph::induced_subgraph(g, which(keep %in% TRUE))
    if (igraph::vcount(g) == 0) {
      stop("No nodes fall inside `lon_range` / `lat_range`.", call. = FALSE)
    }
  }

  # JITTER ----
  if (jitter > 0) {
    set.seed(seed)
    xy <- get_node_coords(g, lat, long)
    n <- igraph::vcount(g)
    g <- igraph::set_vertex_attr(
      g,
      long,
      value = xy$lon + stats::runif(n, -jitter, jitter)
    )
    g <- igraph::set_vertex_attr(
      g,
      lat,
      value = xy$lat + stats::runif(n, -jitter, jitter)
    )
  }

  # BOUNDING BOX ----
  if (!use_ranges) {
    rng <- node_coord_range(g, lat, long, pad = pad)
    lon_range <- rng$lon
    lat_range <- rng$lat
  }
  BB <- c(
    left = min(lon_range),
    bottom = min(lat_range),
    right = max(lon_range),
    top = max(lat_range)
  )

  # TILES ----
  ggmap::register_stadiamaps(key = key, write = FALSE)
  tile <- ggmap::get_stadiamap(BB, zoom = zoom, maptype = maptype)

  # NETWORK ----
  p <- plot_network(g, seed = seed, lat = lat, long = long, ...)

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
    unname() |>
    print()
}
