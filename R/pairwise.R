#' Get pairwise differences for a categorical predictor in
#' an ergm model
#'
#' @param ergm_model fitted ermg model
#' @param term_string pred to perform pairwise on
#' @param max_cells limit on number of comparisons
#'
#' @returns pairwise tibble
#'
#' @export
ergm_pairwise <- function(
  ergm_model,
  term_string,
  max_cells = 50
) {
  ergm_coefs <- stats::coef(object = ergm_model)
  ergm_vcov <- stats::vcov(object = ergm_model)
  ergm_network <- ergm_model$network

  checkmate::assert_numeric(ergm_coefs, finite = TRUE)

  if (
    !term_string %in%
      network::list.vertex.attributes(
        x = ergm_network
      )
  ) {
    rlang::abort(
      "term_string is not a vertex attribute of the network."
    )
  }

  target_cols <- base::grep(
    pattern = term_string,
    x = base::names(x = ergm_coefs),
    value = TRUE,
    fixed = TRUE
  )

  if (base::length(x = target_cols) == 0) {
    rlang::abort(
      "No coefficient names contain term_string."
    )
  }

  mple <- ergm::ergmMPLE(
    formula = ergm_model$formula,
    output = "dyadlist"
  )
  change_stats <- mple$predictor[, base::names(x = ergm_coefs), drop = FALSE]
  target_stats <- change_stats[, target_cols, drop = FALSE]

  vertex_values <- network::get.vertex.attribute(
    x = ergm_network,
    attrname = term_string
  )
  value_levels <- base::levels(x = base::as.factor(x = vertex_values))
  first_index <- base::match(
    x = vertex_values[mple$predictor[, "tail"]],
    table = value_levels
  )
  second_index <- base::match(
    x = vertex_values[mple$predictor[, "head"]],
    table = value_levels
  )

  if (!network::is.directed(x = ergm_network)) {
    lower_index <- base::pmin(first_index, second_index)
    second_index <- base::pmax(first_index, second_index)
    first_index <- lower_index
  }

  pair_order <- (first_index - 1) *
    base::length(x = value_levels) +
    second_index
  pair_labels <- base::paste(
    value_levels[first_index],
    value_levels[second_index],
    sep = "."
  )
  is_match <- first_index == second_index

  cell_keys <- base::apply(
    X = target_stats,
    MARGIN = 1,
    FUN = base::paste,
    collapse = "_"
  )
  cell_ids <- base::match(x = cell_keys, table = base::unique(x = cell_keys))
  cells <- base::order(base::tapply(
    X = pair_order,
    INDEX = cell_ids,
    FUN = base::min
  ))

  if (base::length(x = cells) > max_cells) {
    rlang::abort(
      "Too many distinct dyad types, the term may be continuous or dyad-dependent."
    )
  }

  label_cell <- function(
    cell
  ) {
    in_cell <- cell_ids == cell
    cell_pairs <- base::unique(
      x = pair_labels[in_cell][base::order(pair_order[in_cell])]
    )
    if (base::length(x = cell_pairs) == 1) {
      base::return(cell_pairs)
    }
    if (base::all(is_match[in_cell])) {
      base::return("match")
    }
    if (!base::any(is_match[in_cell])) {
      base::return("no match")
    }
    base::paste(cell_pairs, collapse = ", ")
  }

  cell_labels <- base::vapply(
    X = cells,
    FUN = label_cell,
    FUN.VALUE = base::character(length = 1)
  )

  label_order <- base::order(cell_labels == "no match")
  cells <- cells[label_order]
  cell_labels <- cell_labels[label_order]
  cell_stats <- target_stats[
    base::match(x = cells, table = cell_ids),
    ,
    drop = FALSE
  ]

  linfct_matrix <- base::matrix(
    data = base::colMeans(x = change_stats),
    nrow = base::length(x = cells),
    ncol = base::length(x = ergm_coefs),
    byrow = TRUE,
    dimnames = base::list(cell_labels, base::names(x = ergm_coefs))
  )
  linfct_matrix[, target_cols] <- cell_stats

  ergm_grid <- emmeans::emmobj(
    bhat = ergm_coefs,
    V = ergm_vcov,
    levels = stats::setNames(
      object = base::list(cell_labels),
      nm = term_string
    ),
    linfct = linfct_matrix,
    df = Inf,
    tran = "logit"
  )

  graphics::pairs(
    x = ergm_grid,
    type = "response",
    adjust = "tukey"
  ) |>
    tibble::as_tibble()
}
# DRIVER ----

if (sys.nframe() == 5) {
  pacman::p_load(ergm, emmeans, statnet, tidyverse)
  net <- example_network %>%
    intergraph::asNetwork()
  ergm_model <- suppressMessages(ergm(
    net ~ edges +
      nodematch("genetic_sex") +
      nodecov('lat') +
      nodematch("site", diff = TRUE)
  ))

  ergm_pairwise(
    ergm_model = ergm_model,
    term_string = "site"
  ) |>
    print()
}
