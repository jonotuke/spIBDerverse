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
