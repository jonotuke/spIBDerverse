#' default image
#'
#' A single image as place holder
#'
#' @format An igraph object
#' \describe{
#' \item{row}{row}
#' \item{col}{column}
#' \item{pixel}{pixel}
#' }
#' @source 1980s
"default_image"

#' Example network of 20 European cities
#'
#' A small undirected igraph network of 20 European capitals and major
#' cities, with made-up transport links between them. Useful for trying out
#' [plot_staticmap()] at a continental scale.
#'
#' @format An igraph object with 20 vertices and 29 edges.
#'
#' Vertex attributes:
#' \describe{
#'   \item{name, site}{City name.}
#'   \item{country}{Country the city is in.}
#'   \item{region}{Broad region: "West", "South", "Central", "East" or
#'     "North".}
#'   \item{lat, long}{Latitude and longitude in decimal degrees.}
#'   \item{population}{Approximate city-proper population, in millions.}
#' }
#'
#' Edge attributes:
#' \describe{
#'   \item{edge_type}{Type of link: "rail", "road", "ferry" or "air".}
#'   \item{weight}{Made-up number of connections per week.}
#' }
#'
#' @source Coordinates and populations are approximate; links and weights
#'   are invented for illustration. See `data-raw/europe_network.R`.
#'
#' @examples
#' igraph::vertex_attr(europe_network, "site")
"europe_network"

#' example network
#'
#' An igraph example network
#'
#' @format An igraph object
#' \describe{
#' \item{genetic}{Genetic sex for each sample with levels F or M}
#' \item{site}{Site for each sample with levels A, B, or C}
#' \item{name}{Name for each node}
#' \item{degree}{Degree for each node}
#' \item{lat}{Latitude for each node}
#' \item{long}{Longitude for each node}
#' \item{wij}{Weight for each edge}
#' }
#' @source Simulation via ergm package
"example_network"

#' example network 2
#'
#' An igraph example network
#'
#' @format An igraph object
#' \describe{
#' \item{name}{Name for each node}
#' \dots
#' \item{degree}{Degree for each node}
#' \item{wij}{Weight for each edge}
#' }
#' @source Example IBD datasets from Dr Adam Rohrlach
"example_network_2"

#' example network 3
#'
#' An igraph example network
#' This one has missing node attributes
#'
#' @format An igraph object
#' \describe{
#' \item{name}{Name for each node}
#' \dots
#' \item{degree}{Degree for each node}
#' \item{wij}{Weight for each edge}
#' }
#' @source Based on example_network
"example_network_3"

#' example network 4
#'
#' An igraph example network
#' This one has missing lat and long attributes
#'
#' @format An igraph object
#' \describe{
#' \item{name}{Name for each node}
#' \dots
#' \item{degree}{Degree for each node}
#' \item{wij}{Weight for each edge}
#' }
#' @source Based on example_network
"example_network_4"

#' example network 5
#'
#' An igraph example network
#'
#' @format An igraph object
#' \describe{
#' \item{name}{Name for each node}
#' \item{period}{Simulated period}
#' \dots
#' \item{degree}{Degree for each node}
#' \item{wij}{Weight for each edge}
#' }
#' @source Example IBD datasets from Dr Adam Rohrlach
"example_network_5"

#' example sf object
#'
#' The example network as an sf object
#'
#' @format Two SF objects
#' \describe{
#' \item{nodes_sf}{SF object for nodes}
#' \item{ndges_sf}{SF object for edges}
#' }
#' @source Simulation via ergm package
"example_sf"
