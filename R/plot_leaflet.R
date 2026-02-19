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
# example_sf <- convert_sf(example_network, "lat", "long")
# example_sf
# plot_leaflet(example_network, "lat", "long", col = "genetic_sex")
