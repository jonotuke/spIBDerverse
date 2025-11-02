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
#' plot leaflet
#'
#' @param g igraph object
#' @param lat vertex attribute that gives latitude
#' @param lon vertex attribute that gives longitude
#' @param col vertex attribute to give marker colour
#' @param tile background tile
#'
#' @return leaflet plot
#' @export
#'
#' @examples
#' plot_leaflet(example_network, "lat", "long", col = "site")
plot_leaflet <- function(
  g,
  lat,
  lon,
  col = "site",
  tile = "Default"
) {
  node_df <- igraph::as_data_frame(g, what = "vertices")
  node_df <- node_df |>
    dplyr::rename(lat = dplyr::all_of(lat), lon = dplyr::all_of(lon))
  if (col == "none") {
    node_df$col <- "black"
    node_df <- node_df |>
      dplyr::mutate(label = name)
  } else {
    node_df <- node_df |>
      dplyr::rename(col = dplyr::all_of(col)) |>
      dplyr::mutate(label = stringr::str_glue("{name}: {col}"))
  }
  edges_df <- edges_to_sf(g, lat, lon)
  icon_col <- c(
    "red",
    "darkred",
    "lightred",
    "orange",
    "beige",
    "green",
    "darkgreen",
    "lightgreen",
    "blue",
    "darkblue",
    "lightblue",
    "purple",
    "darkpurple",
    "pink",
    "cadetblue",
    "white",
    "gray",
    "lightgray",
    "black"
  )
  icon_col <- sample(icon_col)
  icons <- leaflet::awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = icon_col[as.numeric(factor(node_df$col))]
  )
  leaf <- leaflet::leaflet(node_df) |>
    leaflet::addTiles() |>
    leaflet::addPolylines(
      data = edges_df,
      color = "grey",
      weight = 5
    ) |>
    leaflet::addAwesomeMarkers(
      clusterOptions = leaflet::markerClusterOptions(),
      label = ~label,
      icon = icons,
      lng = ~lon,
      lat = ~lat
    )
  if (tile == "Default") {
    return(leaf)
  } else if (tile == "Terrain") {
    return(
      leaf |>
        leaflet::addProviderTiles(
          leaflet::providers$Stadia.StamenTerrain
        )
    )
  } else {
    leaf |>
      leaflet::addProviderTiles(
        leaflet::providers$Stadia.StamenTerrainBackground
      )
  }
}
# pacman::p_load(conflicted, tidyverse, targets, leaflet, sp, igraph)
# example_network
# plot_leaflet(example_network, "lat", "long", col = "genetic_sex") |>
#   print()
