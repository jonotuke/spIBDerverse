get_lat_range <- function(network_sf, type = "lat") {
  bb <- sf::st_bbox(network_sf$nodes_sf)
  names(bb) <- NULL
  if (type == "lat") {
    c(bb[2], bb[4])
  } else {
    c(bb[1], bb[3])
  }
}
# get_lat_range(example_sf, "lon")
