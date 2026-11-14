#' Filter network
#'
#' @param g ibd network
#' @param node_filters named list of cutoffs to filter nodes on, one per node
#'   attribute, e.g. `list(site = c("A", "C"), genetic_sex = "F")`. A node
#'   must satisfy every filter to be kept.
#' @param edge_filters named list of cutoffs to filter edges on, one per edge
#'   attribute, e.g. `list(ibd = c(0.25, NA), type = "related")`. An edge must
#'   satisfy every filter to be kept.
#'
#' @details
#' Numeric attributes are filtered on a `c(min, max)` range (inclusive, `NA`
#' bounds are unbounded); all other attributes are filtered on the set of
#' values to keep. Missing values never pass a filter.
#'
#' @return filtered IBD network
#' @export
filter_network <- function(
  g,
  node_filters = list(),
  edge_filters = list()
) {
  # Node filters: a node must satisfy every filter to be kept
  if (length(node_filters) > 0) {
    keep <- attr_filters_keep(g, node_filters, "node")
    g <- igraph::induced_subgraph(g, igraph::V(g)[keep])
  }

  # Edge filters: an edge must satisfy every filter to be kept
  if (length(edge_filters) > 0) {
    keep <- attr_filters_keep(g, edge_filters, "edge")
    g <- igraph::subgraph_from_edges(g, igraph::E(g)[keep])
  }

  g <- g |> add_centrality_measures()
  g
}

#' Combine a set of attribute filters into one keep vector
#'
#' @param g An igraph object.
#' @param filters named list: attribute -> cutoff
#' @param what Either `"node"` or `"edge"`.
#'
#' @return logical vector, one per node (or edge), `TRUE` if every filter
#'   passes
#' @noRd
attr_filters_keep <- function(g, filters, what = c("node", "edge")) {
  what <- match.arg(what)
  arg <- paste0("`", what, "_filters`")

  cols <- names(filters)
  if (is.null(cols) || any(cols == "")) {
    rlang::abort(paste0(arg, " must be a named list"))
  }

  available <- switch(
    what,
    node = igraph::vertex_attr_names(g),
    edge = igraph::edge_attr_names(g)
  )
  missing_cols <- setdiff(cols, available)
  if (length(missing_cols) > 0) {
    rlang::abort(paste0(
      "Unknown ",
      what,
      " attribute(s): ",
      paste(missing_cols, collapse = ", ")
    ))
  }

  empty <- vapply(filters, is.null, logical(1))
  if (any(empty)) {
    rlang::abort(paste0(
      "No cutoff given for ",
      what,
      " attribute(s): ",
      paste(cols[empty], collapse = ", ")
    ))
  }

  n <- switch(what, node = igraph::vcount(g), edge = igraph::ecount(g))
  keep <- rep(TRUE, n)
  for (col in cols) {
    values <- switch(
      what,
      node = igraph::vertex_attr(g, col),
      edge = igraph::edge_attr(g, col)
    )
    keep <- keep & attr_in_cutoff(values, filters[[col]], col)
  }
  keep
}

#' Test which attribute values fall within a cutoff
#'
#' Numeric values are tested against a `c(min, max)` range (inclusive, `NA`
#' bounds are treated as unbounded); all other values are tested for
#' membership in `cutoff`. Missing values never pass.
#'
#' @param values attribute values
#' @param cutoff range or set of values to keep
#' @param column attribute name, used in error messages
#'
#' @return logical vector the same length as `values`, with no `NA`s
#' @noRd
attr_in_cutoff <- function(values, cutoff, column = "attribute") {
  if (is.numeric(values)) {
    cutoff <- suppressWarnings(
      as.numeric(cutoff)
    )
    if (length(cutoff) != 2) {
      rlang::abort(paste0(
        "The cutoff for numeric attribute `",
        column,
        "` must be a range of length 2"
      ))
    }
    lo <- if (is.na(cutoff[1])) -Inf else cutoff[1]
    hi <- if (is.na(cutoff[2])) Inf else cutoff[2]
    keep <- values >= lo & values <= hi
  } else {
    keep <- as.character(values) %in% as.character(cutoff)
  }
  keep & !is.na(keep)
}

if (sys.nframe() == 5) {
  filter_network(
    example_network,
    node_filters = list(site = "A", genetic_sex = "F")
  ) |>
    print()
}
