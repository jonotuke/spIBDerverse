#' clean model names
#'
#' @param x vector of ergm model names
#'
#' @return cleaned vector
#' @export
#'
#' @examples
#' ergms <- example_network |>
#'   get_ergms(c("site", "genetic_sex"), c("nodemix", "nodematch")) |>
#'   purrr::map(broom::glance) |>
#'   purrr::list_rbind(names_to = "model")
#' clean_models(ergms$model) |> print()
clean_models <- function(x) {
  x |>
    stringr::str_remove_all(' ') |>
    stringr::str_replace_all("^network~edges$", "null model") |>
    stringr::str_remove_all("^.*~edges\\+") |>
    stringr::str_remove_all("'") |>
    stringr::str_replace_all('nodecov', 'sum') |>
    stringr::str_replace_all('absdiff', 'diff') |>
    stringr::str_replace_all("nodematch\\((.*),diff=TRUE\\)", "nodediff(\\1)")
}
#' Clean network
#'
#' Removes all nodes with NAs for a given attribute
#' so can fit ERGM models
#'
#' @param g IBD igraph obj
#' @param col node attribute
#'
#' @return cleaned IBD igraph obj
#' @export
#'
#' @examples
#' clean_network(example_network_3, "site")
clean_network <- function(g, col) {
  index <- which(is.na(igraph::vertex_attr(g, col)))
  g <- igraph::delete_vertices(g, igraph::V(g)[index])
  g
}
utils::globalVariables(
  c("term", "estimate", "theta", "term")
)
theta_to_phi <- function(theta0, theta1) {
  p0 <- exp(theta0) / (1 + exp(theta0))
  p1 <- exp(theta0 + theta1) / (1 + exp(theta0 + theta1))
  p1 / p0
}
#' Convert ergm coefficients to fold changes
#'
#' The fold changes are all based on comparison to reference level
#'
#' @param ergm an ergm fit
#' @param trim whether to remove coefficients where the coefficient is -Inf
#'
#' @return tibble of fold changes
#' @export
#'
#' @examples
#' ergm <- get_ergms(example_network, preds = "site", types = "nodemix")
#' get_ergm_fc(ergm[[1]])
get_ergm_fc <- function(ergm, trim = TRUE) {
  coef <- ergm |>
    broom::tidy() |>
    dplyr::select(term, theta = estimate)
  theta_0 <- coef |>
    dplyr::filter(term == "edges") |>
    dplyr::pull(theta)
  coef <- coef |>
    dplyr::mutate(
      phi = dplyr::case_when(
        term == "edges" ~ theta_to_phi(theta_0, 0),
        TRUE ~ theta_to_phi(theta0 = theta_0, theta1 = theta)
      )
    )
  if (trim) {
    coef <- coef |> dplyr::filter(theta != -Inf)
  }
  coef
}
#' convert_pred_terms
#'
#' @param pred name of igraph vertex attribute
#' @param type ergm term type
#'
#' @return ergm term for attribute based on class
#' @export
#'
#' @examples
#' convert_pred_ergmterm("site", "nodecov")
convert_pred_ergmterm <- function(pred, type) {
  type <- stringr::str_split(type, "\\|") |> purrr::pluck(1)
  n_term <- length(type)
  ergm_term <- character(n_term)
  for (i in 1:n_term) {
    ergm_term[i] <- dplyr::case_when(
      type[i] == "nodecov" ~ stringr::str_glue("nodecov('{pred}')"),
      type[i] == "absdiff" ~ stringr::str_glue("absdiff('{pred}')"),
      type[i] == "nodematch" ~ stringr::str_glue("nodematch('{pred}')"),
      type[i] == "nodematch(diff)" ~ stringr::str_glue(
        "nodematch('{pred}', diff = TRUE)"
      ),
      type[i] == "nodemix" ~ stringr::str_glue("nodemix('{pred}')"),
      TRUE ~ pred
    )
  }
  ergm_term
}
#' get_all_models
#'
#' this function returns all possible models with the outcome variable y, and the predictors preds.
#'
#' @param preds vector of igraph attributes
#' @param y outcome variable
#' @param constant constant term
#'
#' @return a vector of strings of linear models
#' @export
#'
#' @examples
#' get_all_models(c("X1", "X2"), "y", "1")
get_all_models <- function(preds, y, constant = "edges") {
  models <- 1:length(preds) |>
    purrr::map(\(i) utils::combn(preds, i, simplify = FALSE)) |>
    unlist(recursive = FALSE) |>
    purrr::map(\(x) stringr::str_c(x, collapse = " + ")) |>
    purrr::map(\(x) stringr::str_glue("{y} ~ {constant} + {x}"))
  models[[length(models) + 1]] <- stringr::str_glue("{y} ~ {constant}")
  models
}
#' drop_missing_nodes
#'
#' Removes every vertex that has a missing value (NA) in any of the given
#' vertex attributes, along with its edges. If any vertices are removed, a
#' warning of class `ergm_missing_nodes_warning` is signalled so it can be
#' caught (e.g. in shiny) and shown to the user.
#'
#' @param network igraph object
#' @param preds vector of igraph vertex attribute names
#'
#' @return the igraph object with incomplete vertices removed. The removed
#'   vertices (names, or indices if unnamed) are stored in
#'   `attr(result, "removed_nodes")`.
#' @export
#'
#' @examples
#' drop_missing_nodes(example_network, c("site", "genetic_sex"))
drop_missing_nodes <- function(network, preds) {
  preds <- unique(preds)
  absent <- setdiff(preds, igraph::vertex_attr_names(network))
  if (length(absent) > 0) {
    rlang::abort(
      paste0(
        "These predictors are not vertex attributes of the network: ",
        paste(absent, collapse = ", ")
      ),
      class = "ergm_missing_attribute_error"
    )
  }

  # one logical column per predictor: TRUE where the value is missing
  missing_by_pred <- purrr::map(
    preds,
    \(p) is.na(igraph::vertex_attr(network, p))
  ) |>
    purrr::set_names(preds)
  is_incomplete <- Reduce(`|`, missing_by_pred)

  if (!any(is_incomplete)) {
    attr(network, "removed_nodes") <- character(0)
    return(network)
  }

  if (all(is_incomplete)) {
    rlang::abort(
      "Every node has a missing value in at least one predictor; no models can be fitted.",
      class = "ergm_missing_attribute_error"
    )
  }

  removed_ids <- if ("name" %in% igraph::vertex_attr_names(network)) {
    igraph::V(network)$name[is_incomplete]
  } else {
    as.character(which(is_incomplete))
  }

  # e.g. "site (3), genetic_sex (1)"
  counts <- purrr::map_int(missing_by_pred, sum)
  counts <- counts[counts > 0]
  by_pred <- paste0(names(counts), " (", counts, ")", collapse = ", ")

  n_removed <- sum(is_incomplete)
  n_total <- igraph::vcount(network)

  network <- igraph::delete_vertices(network, which(is_incomplete))
  attr(network, "removed_nodes") <- removed_ids

  rlang::warn(
    paste0(
      "Removed ",
      n_removed,
      " of ",
      n_total,
      " nodes with missing values before fitting models. ",
      "Missing values by predictor: ",
      by_pred,
      "."
    ),
    class = "ergm_missing_nodes_warning",
    removed_nodes = removed_ids,
    n_removed = n_removed,
    n_total = n_total
  )

  network
}
#' get_ergms
#'
#' Given node attributes and a network, fits all possible ergms. Nodes with
#' missing values in any of `preds` are removed first (see
#' [drop_missing_nodes()]), and all models are fitted to the same reduced
#' network so they remain comparable.
#'
#' @param network igraph object
#' @param preds vector of predictors
#' @param types vector of ergm term types
#'
#' @return list of ergm models. The removed vertices are stored in
#'   `attr(result, "removed_nodes")`.
#' @export
#'
#' @examples
#' get_ergms(example_network, c("site", "genetic_sex"), c("nodematch", "nodemix"))
get_ergms <- function(network, preds = NULL, types = NULL) {
  removed_nodes <- character(0)
  if (is.null(preds)) {
    models <- list()
    models[["null"]] <- "network ~ edges"
  } else {
    network <- drop_missing_nodes(network, preds)
    removed_nodes <- attr(network, "removed_nodes")
    terms <- purrr::map2(preds, types, \(x, y) convert_pred_ergmterm(x, y))
    terms <- unlist(terms)
    models <- get_all_models(terms, "network")
    models <- remove_redundant_models(models, preds)
  }
  network <- intergraph::asNetwork(network)
  fits <- models |>
    purrr::set_names() |>
    purrr::map(\(x) {
      suppressMessages(
        ergm::ergm(stats::as.formula(x))
      )
    })
  attr(fits, "removed_nodes") <- removed_nodes
  fits
}
utils::globalVariables(
  c("xrel", "xmin", "xmax", "model")
)
#' Plots BIC
#'
#' Final version is based on BR's version
#'
#' @param ergms a list of ergms
#' @param text_size size of x axis text
#' @param text_angle angle of x-axis text
#' @param abbr boolean to clean up names
#' @param measure decide if AIC or BIC.
#' @param top_5 boolean to show just top 5 models
#'
#' @return plot
#' @export
#'
#' @examples
#' ergms <- example_network |>
#'   get_ergms(
#'     preds = c("site", "genetic_sex"),
#'     types = c("nodematch", "nodemix"))
#' plot_ergm_bic(ergms) |> print()
plot_ergm_bic <- function(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
) {
  n_coef <- ergms |>
    purrr::map(broom::tidy) |>
    purrr::map(\(x) tibble::tibble(n_coef = nrow(x))) |>
    purrr::list_rbind(names_to = "model")
  model_summaries <- ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "model") |>
    dplyr::left_join(n_coef, by = "model")
  model_summaries <- model_summaries |>
    dplyr::arrange(n_coef, .data[[measure]]) |>
    dplyr::mutate(xrel = 1:dplyr::n())
  if (top_5) {
    model_summaries <- model_summaries |> dplyr::slice(1:5)
  }
  rect_tab <- model_summaries |>
    dplyr::group_by(n_coef) |>
    dplyr::summarise(
      xmin = min(xrel) - 0.5,
      xmax = max(xrel) + 0.5,
    )
  if (abbr) {
    model_summaries <- model_summaries |>
      dplyr::mutate(
        model = clean_models(model)
      )
  }
  model_summaries |>
    dplyr::mutate(best = .data[[measure]] == min(.data[[measure]])) |>
    ggplot2::ggplot(
      ggplot2::aes(x = xrel, y = .data[[measure]], group = 1)
    ) +
    ggplot2::theme_bw() +
    ggplot2::geom_rect(
      inherit.aes = FALSE,
      data = rect_tab,
      ggplot2::aes(
        ymin = -Inf,
        ymax = Inf,
        xmin = xmin,
        xmax = xmax,
        alpha = n_coef
      )
    ) +
    ggplot2::geom_line(linetype = 'dashed') +
    ggplot2::geom_point(pch = 19, size = 6) +
    ggplot2::geom_text(ggplot2::aes(label = n_coef), col = 'white') +
    ggplot2::geom_point(
      data = model_summaries |>
        dplyr::filter(.data[[measure]] == min(.data[[measure]])),
      pch = 19,
      size = 5,
      col = 'red'
    ) +
    ggplot2::geom_text(
      data = model_summaries |>
        dplyr::filter(.data[[measure]] == min(.data[[measure]])),
      ggplot2::aes(label = n_coef),
      col = 'black'
    ) +
    ggplot2::scale_x_continuous(
      breaks = model_summaries$xrel,
      labels = model_summaries$model,
      expand = c(0, 0)
    ) +
    ggplot2::scale_alpha_continuous(
      range = c(0.1, 0.5),
      name = '# coeffcients'
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = text_angle,
        hjust = 1
      ),
      legend.position = 'none',
      axis.text = ggplot2::element_text(size = text_size)
    ) +
    # ggplot2::labs(x = NULL, y = measure)
    ggplot2::xlab(NULL)
}
utils::globalVariables(
  c("xrel", "xmin", "xmax", "model")
)
#' Plots BIC
#'
#' Final version is based on BR's version
#'
#' @param ergms a list of ergms
#' @param text_size size of x axis text
#' @param text_angle angle of x-axis text
#' @param abbr boolean to clean up names
#' @param measure decide if AIC or BIC.
#' @param top_5 boolean to show just top 5 models
#'
#' @return plot
#' @export
#'
#' @examples
#' ergms <- example_network |>
#'   get_ergms(
#'     preds = c("site", "genetic_sex"),
#'     types = c("nodematch", "nodemix"))
#' plot_ergm_bic(ergms) |> print()
plot_ergm_bic <- function(
  ergms,
  text_size = 10,
  text_angle = 90,
  abbr = FALSE,
  measure = "BIC",
  top_5 = FALSE
) {
  n_coef <- ergms |>
    purrr::map(broom::tidy) |>
    purrr::map(\(x) tibble::tibble(n_coef = nrow(x))) |>
    purrr::list_rbind(names_to = "model")
  model_summaries <- ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "model") |>
    dplyr::left_join(n_coef, by = "model")
  model_summaries <- model_summaries |>
    dplyr::arrange(n_coef, .data[[measure]]) |>
    dplyr::mutate(xrel = 1:dplyr::n())
  if (top_5) {
    model_summaries <- model_summaries |> dplyr::slice(1:5)
  }
  rect_tab <- model_summaries |>
    dplyr::group_by(n_coef) |>
    dplyr::summarise(
      xmin = min(xrel) - 0.5,
      xmax = max(xrel) + 0.5,
    )
  if (abbr) {
    model_summaries <- model_summaries |>
      dplyr::mutate(
        model = clean_models(model)
      )
  }
  model_summaries |>
    dplyr::mutate(best = .data[[measure]] == min(.data[[measure]])) |>
    ggplot2::ggplot(
      ggplot2::aes(x = xrel, y = .data[[measure]], group = 1)
    ) +
    ggplot2::theme_bw() +
    ggplot2::geom_rect(
      inherit.aes = FALSE,
      data = rect_tab,
      ggplot2::aes(
        ymin = -Inf,
        ymax = Inf,
        xmin = xmin,
        xmax = xmax,
        alpha = n_coef
      )
    ) +
    ggplot2::geom_line(linetype = 'dashed') +
    ggplot2::geom_point(pch = 19, size = 6) +
    ggplot2::geom_text(ggplot2::aes(label = n_coef), col = 'white') +
    ggplot2::geom_point(
      data = model_summaries |>
        dplyr::filter(.data[[measure]] == min(.data[[measure]])),
      pch = 19,
      size = 5,
      col = 'red'
    ) +
    ggplot2::geom_text(
      data = model_summaries |>
        dplyr::filter(.data[[measure]] == min(.data[[measure]])),
      ggplot2::aes(label = n_coef),
      col = 'black'
    ) +
    ggplot2::scale_x_continuous(
      breaks = model_summaries$xrel,
      labels = model_summaries$model,
      expand = c(0, 0)
    ) +
    ggplot2::scale_alpha_continuous(
      range = c(0.1, 0.5),
      name = '# coeffcients'
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = text_angle,
        hjust = 1
      ),
      legend.position = 'none',
      axis.text = ggplot2::element_text(size = text_size)
    ) +
    # ggplot2::labs(x = NULL, y = measure)
    ggplot2::xlab(NULL)
}
#' Plot single ergm coefficients
#'
#' @param ergm ergm model
#' @param type either "theta" or "phi" - fold changes
#' @param trim remove -Inf coefficients
#'
#' @return plot of coefficients
#' @export
#'
#' @examples
#' ergms <- get_ergms(
#'   example_network,
#'   preds = c("site", "genetic_sex"),
#'   types = c("nodematch", "nodemix")
#' )
#' ergms[[1]] |> plot_single_ergm_coef()
plot_single_ergm_coef <- function(
  ergm,
  type = "theta",
  trim = TRUE
) {
  if (type == "theta") {
    xlab <- "Coefficient of ERGM"
    cutoff <- 0
  } else {
    xlab <- "Fold change compared to edges"
    cutoff <- 1
  }
  coef <- get_ergm_fc(ergm, trim = trim) |>
    dplyr::mutate(
      term = forcats::fct_reorder(term, .data[[type]]),
      sign = ifelse(.data[[type]] > cutoff, "+ve", "-ve")
    )
  coef |>
    ggplot2::ggplot(
      ggplot2::aes(.data[[type]], term, fill = sign)
    ) +
    ggplot2::geom_col(show.legend = FALSE) +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::theme_bw() +
    ggplot2::labs(x = xlab)
}
#' Plot ergm coefficients
#'
#' @param ergms list of ergm fits
#' @param type either "theta" or "phi" - fold changes
#' @param trim remove -Inf coefficients
#' @param models models to show
#'
#' @return plot of coefficients
#' @export
#'
#' @examples
#' ergms <- get_ergms(
#'   example_network,
#'   preds = c("site", "genetic_sex"),
#'   types = c("nodematch", "nodemix")
#' )
#' ergms |> plot_ergm_coef()
plot_ergm_coef <- function(
  ergms,
  type = "theta",
  trim = TRUE,
  models = NULL
) {
  if (type == "theta") {
    xlab <- "Coefficient of ERGM"
    cutoff <- 0
  } else {
    xlab <- "Fold change compared to edges"
    cutoff <- 1
  }
  if (is.null(models)) {
    return(NULL)
  }
  coef <- ergms |>
    purrr::map(get_ergm_fc, trim = trim) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::group_by(Model) |>
    dplyr::mutate(
      term = tidytext::reorder_within(term, .data[[type]], Model),
      sign = ifelse(.data[[type]] > cutoff, "+ve", "-ve")
    )
  coef <- coef |>
    dplyr::filter(Model %in% models)
  coef |>
    ggplot2::ggplot(
      ggplot2::aes(.data[[type]], term, fill = sign)
    ) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::facet_wrap(
      ~Model,
      scales = "free_y",
      space = "free_y",
      ncol = 1
    ) +
    tidytext::scale_y_reordered() +
    harrypotter::scale_fill_hp_d("Ravenclaw") +
    ggplot2::theme_bw() +
    ggplot2::labs(x = xlab)
}
utils::globalVariables(
  c(
    "mcmc.error",
    "phi",
    "std.error",
    "statistic",
    "p.value"
  )
)
#' Gets coefficients and fold changes for a ergm model
#'
#' @param ergm ergm model
#'
#' @returns coefficient table
#'
#' @export
#' @examples
#' ergms <- get_ergms(
#' example_network,
#' preds = c("site", "genetic_sex"),
#' types = c("nodematch", "nodematch")
#' )
#' ergms[[1]] |> get_ergm_coef()
get_ergm_coef <- function(ergm) {
  coef <- broom::tidy(ergm)
  fc <- get_ergm_fc(ergm)
  coefs <- coef |> dplyr::left_join(fc, by = "term")
  coefs |>
    dplyr::select(
      term,
      coef = theta,
      fold_change = phi,
      std.error,
      statistic,
      p.value
    )
}
#' Tab ergm coefficients
#'
#' @param ergms list of ergm fits
#' @param models models to show
#'
#' @return plot of coefficients
#' @export
#'
#' @examples
#' ergms <- get_ergms(
#'   example_network,
#'   preds = c("site", "genetic_sex"),
#'   types = c("nodematch", "nodemix")
#' )
#' ergms |> plot_ergm_coef()
tab_ergm_coef <- function(
  ergms,
  models = NULL
) {
  if (is.null(models)) {
    return(NULL)
  }
  coef <- ergms |>
    purrr::map(get_ergm_coef) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::group_by(Model) |>
    dplyr::filter(Model %in% models) |>
    dplyr::mutate(sign = add_stars(p.value))
  return(coef)
}
utils::globalVariables(
  c("AIC", "BIC", "Model")
)
#' Tabulate the ergm AIC and BIC
#'
#' @param ergms list of ergm fits
#'
#' @return tibble of AIC and BIC for each model
#' @export
#'
#' @examples
#' ergms <- get_ergms(
#'   example_network,
#'   preds = c("site", "genetic_sex"),
#'   types = c("nodematch", "nodemix")
#' )
#' ergms |> get_ergm_bic()
get_ergm_bic <- function(ergms) {
  ergms |>
    purrr::map(broom::glance) |>
    purrr::list_rbind(names_to = "Model") |>
    dplyr::arrange(BIC) |>
    dplyr::select(Model, AIC, BIC)
}
#' remove redundant models
#'
#' @param models list of models
#' @param vars list of variables to filter on
#'
#' @returns list so each var appears only once
#'
#' @export
#' @examples
#' M1 <- "network ~ edges + nodematch('A') + nodemix('A')"
#' M2 <- "network ~ edges + nodematch('A')"
#' remove_redundant_models(list(M1, M2), "A")
remove_redundant_models <- function(models, vars) {
  for (var in vars) {
    models <- models |>
      purrr::discard(\(x) stringr::str_count(x, var) > 1)
  }
  models
}
