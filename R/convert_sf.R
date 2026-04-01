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
#' @param landscape if true changes bounding box to be landscape
#' @param crs default CRS to use, using Web Mercator
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
  jitter = 0,
  landscape = TRUE,
  crs = 3857
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
    crs = crs
  )
  if (jitter > 0) {
    nodes_sf <- sf::st_jitter(nodes_sf, factor = jitter)
  }
  edges_sf <- edges_to_sf(g, lat, lon)
  edges_sf <- edges_sf |> sf::st_set_crs(crs)
  network_sf <- list(nodes_sf = nodes_sf, edges_sf = edges_sf)
  if (landscape) {
    network_sf <- network_sf |> add_convert_bb_adj()
  }
  network_sf
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
# jono_key <- "a7bf69ed-3e77-41ed-b1e2-52f9aa99ec19"
# convert_sf(
#   example_network,
#   "lat",
#   "long"
# ) |>
#   plot_static_map(
#     key = jono_key,
#     zoom = 11
#   )
