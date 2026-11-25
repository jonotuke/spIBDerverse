#' definer
#'
#' @param g igraph object
#' @param edge_filters a list of edge attributes and cutoffs
#'
#' @returns igraph object
#'
#' @export
#' @examples
#' definer(
#' example_network,
#' edge_filters = list(
#' wij = c(0.5, NA), edge_type = "A"
#' )
#' )
definer <- function(g, edge_filters = list()) {
  # Define edge
  if (length(edge_filters) > 0) {
    keep <- keep_edges(g, edge_filters)
    g <- igraph::subgraph_from_edges(
      g,
      igraph::E(g)[keep],
      delete.vertices = FALSE
    )
  }
  # Remove nodes outside crawl
  keep <- igraph::vertex_attr(g, ".crawl") %in% c("seed", "crawl")
  g <- igraph::induced_subgraph(g, igraph::V(g)[keep])
  g
}
#' check if values are in cutoffs
#'
#' @param values vector of values
#' @param cutoff endpoints for numeric, values for categorical
#'
#' @export
#' @returns boolean vector
#' @examples
#' in_cutoff(1:10, c(NA, 5))
in_cutoff <- function(values, cutoff) {
  if (is.numeric(values)) {
    checkmate::assert_numeric(cutoff, len = 2)
    lo <- if (is.na(cutoff[1])) -Inf else cutoff[1]
    hi <- if (is.na(cutoff[2])) Inf else cutoff[2]
    keep <- values >= lo & values <= hi
  } else {
    checkmate::assert_character(cutoff)
    keep <- as.character(values) %in% as.character(cutoff)
  }
  keep & !is.na(keep)
}

#' keep edges
#'
#' @param g igraph obj
#' @param filters list of filters
#'
#' @returns boolean of edges to keep
#'
#' @export
#' @examples
#' keep_edges(
#'    example_network,
#'    filters = list(
#'      wij = c(0.5, NA),
#'      edge_type = "A"
#'    )
#'  )
keep_edges <- function(g, filters = list()) {
  checkmate::assert_list(
    filters,
    names = "unique",
    min.len = 1
  )

  cols <- names(filters)
  checkmate::assertSubset(
    cols,
    igraph::edge_attr_names(g)
  )

  keep <- rep(TRUE, igraph::ecount(g))
  for (col in cols) {
    values <- igraph::edge_attr(g, col)
    keep <- keep & in_cutoff(values, filters[[col]])
  }
  keep
}
