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
  check_node_attributes(g, c(lat, long))
  D <- geo_dist_matrix <- cbind(
    igraph::vertex_attr(g, long),
    igraph::vertex_attr(g, lat)
  ) |>
    geosphere::distm(fun = geosphere::distGeo)
  D <- D / 1000
}
#' Fit spatial ergm
#'
#' Fits an ERGM model to look at the probability of an edge based on
#' spatial distance between nodes
#'
#' @param g igraph object
#' @param lat node attribute for lat
#' @param long node attribute for long
#' @param pred extra predictor for spatial relationship
#'
#' @returns lowest BIC model
#'
#' @export
#' @examples
#' fit_spatial_ergm(example_network, "lat", "long", "site")
fit_spatial_ergm <- function(g, lat, long, pred = NULL) {
  if (!igraph::is_igraph(g)) {
    rlang::abort(
      "Network is not an igraph"
    )
  }
  check_node_attributes(g, c(lat, long, pred))
  D <- get_dist(g, lat, long)
  models <- list()
  models[["dist"]] <- "g ~ edges + edgecov(D)"

  if (!is.null(pred)) {
    if (inherits(igraph::vertex_attr(g, pred), "numeric")) {
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
  models <- models |>
    purrr::set_names() |>
    purrr::map(\(x) ergm::ergm(stats::as.formula(x))) |>
    tibble::enframe(name = "formula", value = "model") |>
    dplyr::mutate(
      BIC = purrr::map_dbl(model, BIC)
    ) |>
    tidyr::unnest(BIC) |>
    dplyr::filter(BIC == min(BIC))
  models$model[[1]]
}
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  fit_spatial_ergm(example_network, "lat", "long") |> print()
  fit_spatial_ergm(example_network, "lat", "long", "site") |> print()
}
