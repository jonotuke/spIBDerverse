#' Convert to SF
#'
#' @description
#' Converts an igraph object into two sf objects
#'
#'
#' @param g igraph network
#' @param lat attribute that gives latitude
#' @param lon attribute that gives longitude
#' @param jitter amount of jitter to add
#'
#' @returns list of edges_sf and nodes_sf
#'
#' @export
#' @examples
#' convert_sf(example_network,"lat","long")
convert_sf <- function(
  g,
  lat,
  lon,
  jitter = 0
) {
  nodes_df <- igraph::as_data_frame(g, what = "vertices")
  nodes_df <- nodes_df |>
    dplyr::rename(
      lat = dplyr::all_of(lat),
      lon = dplyr::all_of(lon)
    )
  nodes_sf <- sf::st_as_sf(
    nodes_df,
    coords = c("lon", "lat"),
    crs = 4326
  )
  if (jitter > 0) {
    nodes_sf <- sf::st_jitter(nodes_sf, factor = jitter)
  }
  edges_sf <- edges_to_sf(g, lat, lon)
  edges_sf <- edges_sf |> sf::st_set_crs(4326)
  list(nodes_sf = nodes_sf, edges_sf = edges_sf)
}
# pacman::p_load(
#   conflicted,
#   tidyverse,
#   targets,
#   leaflet,
#   sp,
#   igraph
# )
# example_network
# convert_sf(
#   example_network,
#   "lat",
#   "long"
# ) |>
#   print()
