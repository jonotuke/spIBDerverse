utils::globalVariables(
  c("distance", "p", "se_logit", "lower", "upper")
)
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
    purrr::map(\(x) {
      suppressMessages(
        ergm::ergm(stats::as.formula(x))
      )
    }) |>
    tibble::enframe(name = "formula", value = "model") |>
    dplyr::mutate(
      BIC = purrr::map_dbl(model, BIC)
    ) |>
    tidyr::unnest(BIC)
  return(models)
}

#' Predicts probability for an edge for given distances
#'
#' @param fit a model from the ERGM package which must have the distance as a predictor
#' @param N the grid density of the fitted distance
#' @param level the confidence level for the error bars
#' @param distance_term name for the distance variable
#'
#' @returns tibble of predicted values
#'
#' @export
#' @examples
#' fit_spatial_ergm(example_network, "lat", "long", "site")$model[[1]] |>
#'  predict_spatial_ergm(N = 100)
predict_spatial_ergm <- function(fit, N, level = 0.95, distance_term = NULL) {
  checkmate::assert_class(fit, "ergm")
  checkmate::assert_numeric(N)
  checkmate::assert_numeric(level)
  # Extract model information
  theta <- stats::coef(fit)
  V <- stats::vcov(fit)
  z <- stats::qnorm(p = 1 - (1 - level) / 2)
  net <- fit$network

  edge_cols <- grep(
    pattern = "^edgecov",
    x = names(theta),
    value = TRUE
  )

  # Get distance variable name
  if (is.null(distance_term)) {
    dist_col <- edge_cols[1]
  } else {
    checkmate::assert_character(distance_term)
    dist_col <- stringr::str_subset(edge_cols, distance_term)
  }

  # list remaining edge and node variable names to get required column names
  held_cols <- setdiff(x = edge_cols, y = dist_col)
  other_cols <- setdiff(x = names(theta), y = dist_col)
  attrs <- stringr::str_extract_all(
    string = deparse1(fit$formula[[3]]),
    pattern = '"[^"]*"'
  )[[1]] |>
    stringr::str_remove_all(pattern = '"') |>
    intersect(y = network::list.vertex.attributes(net))

  # Make matrix of model terms
  X <- ergm::ergmMPLE(formula = fit$formula, output = "dyadlist")$predictor |>
    tibble::as_tibble()

  # Produce variable levels for combined matrix terms
  labels <- purrr::map(
    .x = purrr::set_names(attrs),
    .f = function(a) {
      v <- network::get.vertex.attribute(x = net, attrname = a)
      paste(pmin(v[X$tail], v[X$head]), pmax(v[X$tail], v[X$head]), sep = "/")
    }
  ) |>
    tibble::as_tibble(.rows = nrow(X))
  combos <- dplyr::bind_cols(labels, X) |>
    dplyr::mutate(dplyr::across(
      .cols = dplyr::all_of(held_cols),
      .fns = mean
    )) |>
    dplyr::select(dplyr::all_of(c(attrs, other_cols))) |>
    dplyr::distinct()

  # merge variable levels with distance grid
  grid <- tidyr::expand_grid(
    combos,
    distance = seq(from = 0, to = max(X[[dist_col]]), length.out = N)
  )
  M <- as.matrix(grid[, other_cols])
  M <- cbind(M, grid$distance)
  colnames(M) <- c(other_cols, dist_col)
  M <- M[, names(theta)]

  # calculate point estimate and error bars and return
  eta <- as.vector(M %*% theta)
  se <- sqrt(rowSums((M %*% V) * M))
  out.tibble <- grid |>
    dplyr::mutate(
      p = stats::plogis(eta),
      se_logit = se,
      lower = stats::plogis(eta - z * se),
      upper = stats::plogis(eta + z * se)
    ) |>
    dplyr::select(dplyr::all_of(attrs), distance, p, se_logit, lower, upper)
  return(out.tibble)
}

#' plot spatial ergm
#'
#' @param spatial_pred predict tibble from spatial ergm
#' @param pred predictor to colour by
#'
#' @returns ggplot
#'
#' @export
#' @examples
#' ergms <- fit_spatial_ergm(
#' example_network_5,
#' "Latitude",
#' "Longitude",
#' "period"
#' )
#' ergms$model[[3]] |>
#'  predict_spatial_ergm(N = 100) |>
#'  plot_spatial_ergm("period")
plot_spatial_ergm <- function(spatial_pred, pred = NULL) {
  spatial_pred |>
    ggplot2::ggplot(
      mapping = ggplot2::aes(
        x = distance,
        y = p,
        col = .data[[pred]],
        fill = .data[[pred]]
      )
    ) +
    ggplot2::theme_bw() +
    ggplot2::geom_ribbon(
      mapping = ggplot2::aes(ymin = lower, ymax = upper),
      alpha = 0.5
    ) +
    ggplot2::geom_line(linetype = 'dashed') +
    ggplot2::scale_x_continuous(name = 'Distance (km)') +
    ggplot2::scale_y_continuous(name = 'Probability of Connectedness') +
    ggsci::scale_colour_startrek(name = pred) +
    ggsci::scale_fill_startrek(name = pred)
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  ergms <- fit_spatial_ergm(
    example_network_5,
    "Latitude",
    "Longitude",
    "period"
  )
  ergms$model[[3]] |>
    predict_spatial_ergm(N = 100) |>
    plot_spatial_ergm("period") |>
    print()
}
