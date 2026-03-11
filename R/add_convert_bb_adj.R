#' Expand a line by given amount
#'
#' @param x 2 vector with left and right point of a line
#' @param k amount to increase by
#'
#' @returns 2 vector of new left and right point
#'
expand_line <- function(x, k = 0.1) {
  L <- x[2] - x[1]
  x[1] <- x[1] - k * L
  x[2] <- x[2] + k * L
  return(x)
}
#' Given a bounding box, increase the lat and long by given amounts
#'
#' @param bb bounding box (left, bottom, right, top)
#' @param x_adj lon adjust
#' @param y_adj lat adjust
#'
#' @returns new bounding box
#'
convert_bb <- function(bb, x_adj = 0.1, y_adj = 0.1) {
  bb[c(1, 3)] <- expand_line(c(bb[1], bb[3]), x_adj)
  bb[c(2, 4)] <- expand_line(c(bb[2], bb[4]), y_adj)
  bb
}
#' convert bb to be square
#'
#' @param bb bounding box
#' @param asp aspect ratio, default 1
#'
#' @returns adjusted BB
convert_bb_asp <- function(bb, asp = 1) {
  w <- bb[3] - bb[1]
  h <- bb[4] - bb[2]
  if (w < h) {
    x_adj <- asp * h / w
    y_adj <- 0.1
  } else {
    y_adj <- w / (asp * h)
    x_adj <- 0.1
  }
  convert_bb(bb, x_adj, y_adj)
}
#' Adjust BB for network work sf object
#'
#' @param network_sf network sf objects
#' @param asp aspect ratio
#'
#' @returns same network sf with adjusted aspect ration
#'
#' @export
#' @examples
#' add_convert_bb_adj(example_sf)
add_convert_bb_adj <- function(network_sf, asp = 1) {
  nodes_sf <- network_sf$nodes_sf
  bb <- sf::st_bbox(network_sf$nodes_sf)
  new_bb <- convert_bb_asp(bb, asp = asp)
  attr(sf::st_geometry(network_sf$nodes_sf), "bbox") <- new_bb
  attr(sf::st_geometry(network_sf$edges_sf), "bbox") <- new_bb
  network_sf
}

# pacman::p_load(conflicted, tidyverse, targets)
# add_convert_bb_adj(example_sf) |> print()
