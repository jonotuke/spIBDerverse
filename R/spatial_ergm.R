utils::globalVariables(
  c("p", "se_logit", "lower", "upper", "dist", "head", "tail", "formula")
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
#' @param pred node attribute for non-dist predictor
#'
#' @returns lowest BIC model
#'
#' @export
#' @examples
#' fit_spatial_ergm(example_network, "lat", "long", "site")
fit_spatial_ergm <- function(g, lat, long, pred = "none") {
  if (!igraph::is_igraph(g)) {
    rlang::abort(
      "Network is not an igraph"
    )
  }
  check_node_attributes(g, c(lat, long))
  D <- get_dist(g, lat, long)
  models <- list()
  models[["dist"]] <- "g ~ edges + edgecov(D)"

  if (pred != "none") {
    check_node_attributes(g, pred)
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
  if (pred == "none") {
    model <- models$model[[1]]
  } else {
    models <- models |>
      dplyr::filter(formula != "g ~ edges + edgecov(D)") |>
      dplyr::filter(BIC == min(BIC))
    model <- models$model[[1]]
  }
  model
}

#' Predicts probability for an edge for given distances
#'
#' @param fit a model from the ERGM package which must
#' have the distance as a predictor
#' @param N the grid density of the fitted distance
#' @param level the confidence level for the error bars
#'
#' @returns tibble of predicted values
#'
#' @export
#' @examples
#' fit_spatial_ergm(example_network, "lat", "long", "site") |>
#'  predict_spatial_ergm(N = 100)
predict_spatial_ergm <- function(
  fit,
  N,
  level = 0.95
) {
  checkmate::assert_class(fit, "ergm")
  checkmate::assert_count(N, positive = TRUE)
  checkmate::assert_number(level, lower = 0, upper = 1)

  # Extract model information
  theta <- stats::coef(fit)
  V <- stats::vcov(fit)
  z <- stats::qnorm(p = 1 - (1 - level) / 2)
  g <- fit$network

  dist_pred <- names(theta) |>
    purrr::keep(\(x) stringr::str_detect(x, "^edgecov"))

  if (length(dist_pred) == 0) {
    rlang::abort("Model must contain an edgecov (distance) term")
  }
  if (length(dist_pred) > 1) {
    rlang::abort("Can only deal with one distance function")
  }

  other_terms <- setdiff(names(theta), dist_pred)

  # Quoted strings in the formula that are actual vertex attributes
  preds <- as.character(fit$formula)[3] |>
    stringr::str_extract_all('"[^"]*"') |>
    purrr::pluck(1) |>
    stringr::str_remove_all('"') |>
    unique() |>
    intersect(network::list.vertex.attributes(g))

  # Make matrix of model terms
  X <- ergm::ergmMPLE(
    formula = fit$formula,
    output = "dyadlist"
  )$predictor |>
    tibble::as_tibble()

  dist_seq <- seq(
    from = 0,
    to = max(X[[dist_pred]]),
    length.out = N
  )

  if (length(preds) > 0) {
    # Produce variable levels for combined matrix terms
    labels <- purrr::map(
      .x = purrr::set_names(preds),
      .f = function(a) {
        v <- network::get.vertex.attribute(x = g, attrname = a)
        paste(
          pmin(v[X$tail], v[X$head]),
          pmax(v[X$tail], v[X$head]),
          sep = "/"
        )
      }
    ) |>
      tibble::as_tibble(.rows = nrow(X))

    combos <- dplyr::bind_cols(labels, X) |>
      dplyr::select(-tail, -head, -dplyr::all_of(dist_pred)) |>
      dplyr::distinct()
  } else {
    # Only edgecov (plus e.g. edges): one row of the non-distance terms
    combos <- X |>
      dplyr::select(dplyr::all_of(other_terms)) |>
      dplyr::distinct()

    if (nrow(combos) > 1) {
      rlang::warn(paste(
        "Non-distance terms vary across dyads;",
        "predicting for each observed combination."
      ))
    }
  }

  # Build prediction grid
  if (ncol(combos) == 0) {
    # Model has edgecov only (no edges term)
    grid <- tibble::tibble("{dist_pred}" := dist_seq)
  } else {
    grid <- tidyr::expand_grid(combos, "{dist_pred}" := dist_seq)
  }

  M <- grid |>
    dplyr::select(dplyr::all_of(names(theta))) |>
    as.matrix()

  # Calculate point estimate and error bars and return
  eta <- as.vector(M %*% theta)
  se <- sqrt(rowSums((M %*% V) * M))

  grid |>
    dplyr::mutate(
      p = stats::plogis(eta),
      se_logit = se,
      lower = stats::plogis(eta - z * se),
      upper = stats::plogis(eta + z * se)
    ) |>
    dplyr::select(
      dplyr::all_of(preds),
      dist = dplyr::all_of(dist_pred),
      p,
      se_logit,
      lower,
      upper
    )
}

#' plot spatial ergm
#'
#' @param spatial_pred predict tibble from spatial ergm
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
#' ergms |>
#'  predict_spatial_ergm(N = 100) |>
#'  plot_spatial_ergm()
plot_spatial_ergm <- function(spatial_pred) {
  fixed_cols <- c("dist", "p", "se_logit", "lower", "upper")
  group_cols <- setdiff(names(spatial_pred), fixed_cols)

  # Combine several grouping columns into one, e.g. "A/B : X/Y"
  if (length(group_cols) > 1) {
    pred <- paste(group_cols, collapse = " : ")
    spatial_pred <- spatial_pred |>
      tidyr::unite(col = !!pred, dplyr::all_of(group_cols), sep = " : ")
  } else if (length(group_cols) == 1) {
    pred <- group_cols
  } else {
    pred <- NULL
  }

  single_col <- ggsci::pal_startrek()(1)

  plt <- spatial_pred |>
    ggplot2::ggplot(mapping = ggplot2::aes(x = dist, y = p)) +
    ggplot2::theme_bw() +
    ggplot2::scale_x_continuous(name = "Distance (km)") +
    ggplot2::scale_y_continuous(name = "Probability of Connectedness")

  if (!is.null(pred)) {
    plt +
      ggplot2::aes(col = .data[[pred]], fill = .data[[pred]]) +
      ggplot2::geom_ribbon(
        mapping = ggplot2::aes(ymin = lower, ymax = upper),
        alpha = 0.5
      ) +
      ggplot2::geom_line(linetype = "dashed") +
      ggsci::scale_colour_startrek(name = pred) +
      ggsci::scale_fill_startrek(name = pred)
  } else {
    plt +
      ggplot2::geom_ribbon(
        mapping = ggplot2::aes(ymin = lower, ymax = upper),
        alpha = 0.5,
        fill = single_col,
        colour = single_col
      ) +
      ggplot2::geom_line(linetype = "dashed", colour = single_col)
  }
}

# DRIVER ----
if (sys.nframe() == 5) {
  fit_spatial_ergm(
    example_network_5,
    "Latitude",
    "Longitude",
    "period"
  ) |>
    predict_spatial_ergm(N = 100) |>
    plot_spatial_ergm() |>
    print()
  fit_spatial_ergm(
    example_network_5,
    "Latitude",
    "Longitude"
  ) |>
    predict_spatial_ergm(N = 100) |>
    plot_spatial_ergm() |>
    print()
}
