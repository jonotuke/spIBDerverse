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
    purrr::map(\(x) ergm::ergm(stats::as.formula(x)))
  attr(fits, "removed_nodes") <- removed_nodes
  fits
}
if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets, ergm)
  get_ergms(
    example_network_3,
    preds = c("site", "genetic_sex", ".degree"),
    types = c("nodematch|nodemix", "nodemix|nodematch", "nodecov")
  )
}
