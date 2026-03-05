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
#' get_ergms
#'
#' Given node attributes and a network, fits all possible ergms
#'
#' @param network igraph object
#' @param preds vector of predictors
#' @param types vector of ergm term types
#'
#' @return list of ergm models
#' @export
#'
#' @examples
#' get_ergms(example_network, c("site", "genetic_sex"), c("nodematch", "nodemix"))
get_ergms <- function(network, preds = NULL, types = NULL) {
  if (is.null(preds)) {
    models <- list()
    models[["null"]] <- "network ~ edges"
  } else {
    terms <- purrr::map2(preds, types, \(x, y) convert_pred_ergmterm(x, y))
    terms <- unlist(terms)
    models <- get_all_models(terms, "network")
    models <- remove_redundant_models(models, preds)
  }
  network <- intergraph::asNetwork(network)
  models |>
    purrr::set_names() |>
    purrr::map(\(x) ergm::ergm(stats::as.formula(x)))
}
# pacman::p_load(conflicted, tidyverse, targets, ergm)
# models <- get_ergms(
#   example_network,
#   preds = c("site", "genetic_sex", "degree"),
#   types = c("nodematch|nodemix", "nodemix|nodematch", "nodecov")
# )
# length(models)
