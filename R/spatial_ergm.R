#' Get geodistance for points in network
#'
#' @param g igraph object
#' @param lat node attribute that is lat
#' @param long node attribute that is long
#'
#' @returns distance matrix in km's
#'
#' @export
#' @examples
#' get_dist(example_network, "lat", "long")
get_dist <- function(g, lat, long) {
  D <- geo_dist_matrix <- cbind(
    igraph::vertex_attr(g, long),
    igraph::vertex_attr(g, lat)
  ) |>
    geosphere::distm(fun = geosphere::distGeo)
  D <- D / 1000
}
fit_spatial_ergm <- function(g, lat, long, pred = NULL) {
  D <- get_dist(g, lat, long)
  models <- list()
  models[["dist"]] <- "g ~ edges + edgecov(D)"

  if (!is.null(pred)) {
    if (class(igraph::vertex_attr(g, pred)) == "numeric") {
      models[["cov"]] <- stringr::str_glue(
        "g ~ edges + edgecov(D) + nodecov('{pred}')"
      )
    } else {
      n_levels <- nlevels(factor(igraph::vertex_attr(g, pred)))
      if (n_levels > 2) {
        models[["mix"]] <- stringr::str_glue(
          "g ~ edges + edgecov(D) + nodemix('{pred}')"
        )
      }
      models[["match"]] <- stringr::str_glue(
        "g ~ edges + edgecov(D) + nodematch('{pred}')"
      )
      models[["diff"]] <- stringr::str_glue(
        "g ~ edges + edgecov(D) + nodematch('{pred}', diff = TRUE)"
      )
    }
  }
  g <- intergraph::asNetwork(g)
  fits <- models |>
    purrr::set_names() |>
    purrr::map(\(x) ergm::ergm(stats::as.formula(x)))
  fits
}
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  get_dist(example_network, "lat", "long")
  fit_spatial_ergm(example_network, "lat", "long", "lat") |> print()
}
