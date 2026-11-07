utils::globalVariables(
  c("distance", "p", "se_logit", "lower", "upper")
)
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
#' fit_spatial_ergm(example_network, "lat", "long", "site") |>
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
if (sys.nframe() == 5) {
  ergm <- fit_spatial_ergm(example_network, "lat", "long", "site")
  ergm |> predict_spatial_ergm(N = 10) |> print()
}
