#' Filter network
#'
#' @param g ibd network
#' @param node_filters list of values to filter on for nodes
#'   e.g. list(site = c("A", "C"), genetic_sex = "F")
#' @param edge_column edge attribute to filter network on
#' @param edge_cutoff cutoffs for edge filter
#'
#' @return filtered IBD network
#' @export
filter_network <- function(
  g,
  node_filters = list(),
  edge_column = "none",
  edge_cutoff = NULL
) {
  if (edge_column != "none" && is.null(edge_cutoff)) {
    rlang::abort(
      "You must give a edge_cutoff if you filter on a edge attribute"
    )
  }

  # Node filters: a node must satisfy every filter to be kept
  if (length(node_filters) > 0) {
    cols <- names(node_filters)
    if (is.null(cols) || any(cols == "")) {
      rlang::abort("`node_filters` must be a named list")
    }
    missing_cols <- setdiff(cols, igraph::vertex_attr_names(g))
    if (length(missing_cols) > 0) {
      rlang::abort(paste0(
        "Unknown node attribute(s): ",
        paste(missing_cols, collapse = ", ")
      ))
    }
    empty <- vapply(node_filters, is.null, logical(1))
    if (any(empty)) {
      rlang::abort(paste0(
        "No cutoff given for node attribute(s): ",
        paste(cols[empty], collapse = ", ")
      ))
    }

    keep <- rep(TRUE, igraph::vcount(g))
    for (col in cols) {
      keep <- keep &
        attr_in_cutoff(
          igraph::vertex_attr(g, col),
          node_filters[[col]],
          col
        )
    }
    g <- igraph::induced_subgraph(g, igraph::V(g)[keep])
  }

  if (edge_column != "none") {
    keep <- attr_in_cutoff(
      igraph::edge_attr(g, edge_column),
      edge_cutoff,
      edge_column
    )
    g <- igraph::subgraph_from_edges(g, igraph::E(g)[keep])
  }

  g <- g |> add_centrality_measures()
  g
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
