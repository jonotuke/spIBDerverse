#' Convert to SF
#'
#' @description
#' Converts an igraph object into two sf objects
#'
#'
#' @param g igraph network
#' @param lat attribute that gives latitude
#' @param lon attribute that gives longitude
#'
#' @returns list of edges_sf and nodes_sf
#'
#' @export
#' @examples
#' convert_sf(example_network,"lat","long")
convert_sf <- function(
  g,
  lat,
  lon
) {
  nodes_df <- igraph::as_data_frame(g, what = "vertices")
  nodes_df <- nodes_df |>
    dplyr::rename(
      lat = dplyr::all_of(lat),
      lon = dplyr::all_of(lon)
    )
  # if (col == "none") {
  #   nodes_df$col <- "black"
  #   nodes_df <- nodes_df |>
  #     dplyr::mutate(label = name)
  # } else {
  #   nodes_df <- nodes_df |>
  #     dplyr::rename(col = dplyr::all_of(col)) |>
  #     dplyr::mutate(label = stringr::str_glue("{name}: {col}"))
  # }
  nodes_sf <- sf::st_as_sf(
    nodes_df,
    coords = c("lon", "lat"),
    crs = 4326
  )
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
