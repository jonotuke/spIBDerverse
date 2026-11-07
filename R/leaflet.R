#' edges to sf
#'
#' @param graph igraph obj
#' @param lat lat attribute
#' @param lon long attribute
#'
#' @returns sf edge object
#'
#' @export
#' @examples
#' edges_to_sf(example_network)
edges_to_sf <- function(
  graph,
  lat = "lat",
  lon = "long"
) {
  edges <- igraph::as_data_frame(graph, "edges")

  v_lat <- igraph::vertex_attr(graph, lat)
  v_lon <- igraph::vertex_attr(graph, lon)
  froms <- igraph::tail_of(graph, es = igraph::E(graph))
  tos <- igraph::head_of(graph, es = igraph::E(graph))

  from_lat <- v_lat[froms]
  from_lon <- v_lon[froms]
  to_lat <- v_lat[tos]
  to_lon <- v_lon[tos]

  st_edges <- purrr::pmap(
    list(from_lon, from_lat, to_lon, to_lat),
    \(w, x, y, z) {
      sf::st_linestring(matrix(c(w, x, y, z), 2, 2, byrow = TRUE))
    },
    .progress = TRUE
  )
  sf::st_geometry(edges) <- sf::st_sfc(st_edges)

  edges
}
# Marker colours supported by leaflet::awesomeIcons(), ordered so that
# neighbouring groups get contrasting colours.
# fmt: skip
awesome_marker_colours <- c(
  "red","blue","green",
  "orange","purple","darkred",
  "darkblue","darkgreen","cadetblue",
  "pink","beige","lightblue",
  "lightgreen","lightred","darkpurple",
  "gray","lightgray","white","black"
)

#' Plot an igraph network on a leaflet map
#'
#' Draws each vertex as a clustered marker at its coordinates and each edge
#' as a grey line between the vertices it connects.
#'
#' @param g An igraph object.
#' @param lat Name of the vertex attribute holding latitude.
#' @param lon Name of the vertex attribute holding longitude.
#' @param col Name of the vertex attribute used to colour markers, or `"none"`
#'   to draw every marker in black. Colours are recycled if there are more
#'   than 19 groups.
#' @param label Name(s) of the vertex attribute(s) shown in marker labels,
#'   each on its own line as `attribute: value`, or `"none"` to label markers
#'   with the vertex name.
#' @param tile Background tiles: `"Default"` (OpenStreetMap), `"Terrain"`
#'   (Stadia Stamen Terrain), or any other value for Stadia Stamen Terrain
#'   Background.
#'
#' @return A leaflet htmlwidget.
#' @export
#'
#' @examples
#' plot_leaflet(example_network, "lat", "long", col = "site")
#' plot_leaflet(example_network, "lat", "long", col = "site", label = "site")
#' plot_leaflet(
#'   example_network, "lat", "long",
#'   col = "site", label = c("name", "site")
#' )
plot_leaflet <- function(
  g,
  lat,
  lon,
  col = "site",
  label = "none",
  tile = "Default"
) {
  required <- setdiff(c(lat, lon, col, label), "none")
  absent <- setdiff(required, igraph::vertex_attr_names(g))
  if (length(absent) > 0) {
    stop(
      "Vertex attribute(s) not found in `g`: ",
      paste(absent, collapse = ", "),
      call. = FALSE
    )
  }

  vertex_names <- igraph::V(g)$name
  if (is.null(vertex_names)) {
    vertex_names <- as.character(seq_len(igraph::vcount(g)))
  }

  nodes <- data.frame(
    lat = igraph::vertex_attr(g, lat),
    lon = igraph::vertex_attr(g, lon)
  )

  label_attrs <- setdiff(label, "none")
  label_html <- if (length(label_attrs) == 0) {
    htmltools::htmlEscape(vertex_names)
  } else {
    label_lines <- lapply(label_attrs, function(attr) {
      values <- as.character(igraph::vertex_attr(g, attr))
      paste0(htmltools::htmlEscape(attr), ": ", htmltools::htmlEscape(values))
    })
    do.call(paste, c(label_lines, sep = "<br>"))
  }
  labels <- lapply(label_html, htmltools::HTML)

  marker_colours <- if (col == "none") {
    rep("black", nrow(nodes))
  } else {
    group <- as.integer(factor(igraph::vertex_attr(g, col)))
    awesome_marker_colours[(group - 1) %% length(awesome_marker_colours) + 1]
  }

  icons <- leaflet::awesomeIcons(
    icon = "ios-close",
    iconColor = "black",
    library = "ion",
    markerColor = marker_colours
  )

  map <- leaflet::leaflet(nodes)
  map <- switch(
    tile,
    Default = leaflet::addTiles(map),
    Terrain = leaflet::addProviderTiles(
      map,
      leaflet::providers$Stadia.StamenTerrain
    ),
    leaflet::addProviderTiles(
      map,
      leaflet::providers$Stadia.StamenTerrainBackground
    )
  )

  map |>
    leaflet::addPolylines(
      data = edges_to_sf(g, lat, lon),
      color = "grey",
      weight = 5
    ) |>
    leaflet::addAwesomeMarkers(
      lng = ~lon,
      lat = ~lat,
      label = labels,
      icon = icons,
      clusterOptions = leaflet::markerClusterOptions()
    ) |>
    leaflet::addScaleBar(
      position = "bottomleft",
      options = leaflet::scaleBarOptions(metric = TRUE, imperial = TRUE)
    )
}
