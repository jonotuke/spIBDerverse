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
#' @param pred node attribute for non-dist predictor. If the attribute is
#'   numeric (integer or double) it is fitted with `nodecov()`; otherwise it
#'   is treated as categorical and fitted with `nodematch()`/`nodemix()`.
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
    pred_values <- igraph::vertex_attr(g, pred)
    if (is.numeric(pred_values)) {
      # Numeric predictor (integer or double): main effect via nodecov
      models[["cov"]] <- stringr::str_glue(
        "g ~ edges + edgecov(D) + nodecov('{pred}')"
      )
    } else {
      # Categorical predictor: nodemix / nodematch models
      n_levels <- nlevels(factor(pred_values))
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
#' @param N_cov number of evenly spaced values to predict over for each
#' `nodecov()` term. A `nodecov()` term for a dyad is the sum of the two
#' nodes' attribute values, so the sequence runs from the smallest to the
#' largest observed sum and is returned in a column named `<attribute>_sum`.
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
  level = 0.95,
  N_cov = 100
) {
  checkmate::assert_class(fit, "ergm")
  checkmate::assert_count(N, positive = TRUE)
  checkmate::assert_number(level, lower = 0, upper = 1)
  checkmate::assert_count(N_cov, positive = TRUE)

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

  # Numeric predictors fitted with nodecov are predicted over a sequence;
  # the remaining (categorical) predictors use observed level combinations
  cov_terms <- other_terms[stringr::str_detect(other_terms, "^nodecov\\.")]
  cov_preds <- stringr::str_remove(cov_terms, "^nodecov\\.")
  cov_labels <- paste0(cov_preds, "_sum")
  cat_preds <- setdiff(preds, cov_preds)

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

  cov_seqs <- purrr::map(
    .x = purrr::set_names(cov_terms),
    .f = \(term) {
      seq(
        from = min(X[[term]]),
        to = max(X[[term]]),
        length.out = N_cov
      ) |>
        unique()
    }
  )

  if (length(cat_preds) > 0) {
    # Produce variable levels for combined matrix terms
    labels <- purrr::map(
      .x = purrr::set_names(cat_preds),
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
      dplyr::select(
        -tail,
        -head,
        -dplyr::all_of(c(dist_pred, cov_terms))
      ) |>
      dplyr::distinct()
  } else {
    # No categorical terms (e.g. just edges): one row of the remaining terms
    combos <- X |>
      dplyr::select(dplyr::all_of(setdiff(other_terms, cov_terms))) |>
      dplyr::distinct()

    if (nrow(combos) > 1) {
      rlang::warn(paste(
        "Non-distance terms vary across dyads;",
        "predicting for each observed combination."
      ))
    }
  }

  # Build prediction grid: nodecov sequences crossed with distance
  grid <- tidyr::expand_grid(!!!cov_seqs, "{dist_pred}" := dist_seq)
  if (ncol(combos) > 0) {
    # Cross with observed combinations of the other terms (e.g. edges)
    grid <- tidyr::expand_grid(combos, grid)
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
      dplyr::all_of(cat_preds),
      dplyr::all_of(purrr::set_names(cov_terms, cov_labels)),
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
#' @returns ggplot. If the predictor is numeric (a `nodecov()` term) this is
#' a tile plot with distance on the x-axis, the predictor on the y-axis and
#' fill showing the probability of an edge; otherwise a line plot of
#' probability against distance with confidence ribbons.
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

  # Numeric predictor (e.g. nodecov sequence): heatmap of probability
  num_cols <- group_cols[purrr::map_lgl(spatial_pred[group_cols], is.numeric)]

  if (length(num_cols) > 1) {
    rlang::abort("Can only plot one numeric predictor")
  }

  if (length(num_cols) == 1) {
    facet_cols <- setdiff(group_cols, num_cols)

    plt <- spatial_pred |>
      ggplot2::ggplot(
        mapping = ggplot2::aes(x = dist, y = .data[[num_cols]], fill = p)
      ) +
      ggplot2::geom_tile() +
      ggplot2::theme_bw() +
      ggplot2::scale_x_continuous(name = "Distance (km)", expand = c(0, 0)) +
      ggplot2::scale_y_continuous(name = num_cols, expand = c(0, 0)) +
      ggplot2::scale_fill_viridis_c(name = "Probability of\nConnectedness")

    # Any categorical predictors are shown as facets
    if (length(facet_cols) > 0) {
      plt <- plt +
        ggplot2::facet_wrap(ggplot2::vars(!!!rlang::syms(facet_cols)))
    }
    return(plt)
  }

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
    "Longitude",
    pred = "n_cov_snp"
  ) |>
    predict_spatial_ergm(N = 100) |>
    plot_spatial_ergm() |>
    print()
}
