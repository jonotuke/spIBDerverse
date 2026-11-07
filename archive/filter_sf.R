#' Filter SF object
#'
#' @param sf_obj object with node and edge df
#' @param xmin left long border
#' @param xmax right long border
#' @param ymin bottom lat border
#' @param ymax top lat border
#'
#' @returns filter SF object
#'
#' @export
filter_sf <- function(sf_obj, xmin, xmax, ymin, ymax) {
  nodes_sf <- sf_obj[["nodes_sf"]]
  edges_sf <- sf_obj[["edges_sf"]]
  nodes_sf <- sf::st_crop(
    nodes_sf,
    xmin = xmin,
    xmax = xmax,
    ymin = ymin,
    ymax = ymax
  )
  edges_sf <- sf::st_crop(
    edges_sf,
    xmin = xmin,
    xmax = xmax,
    ymin = ymin,
    ymax = ymax
  )
  list(nodes_sf = nodes_sf, edges_sf = edges_sf)
}
# network_sf <- convert_sf(
#   example_network_2,
#   "Latitude",
#   "Longitude",
#   col = "site"
# )
# network_sf |>
#   filter_sf(xmin = 19, xmax = 21, ymin = 46, ymax = 47.5) |>
#   plot_map(zoom = 9)
