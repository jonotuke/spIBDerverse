#' classify edges
#'
#' @param g igraph obj
#' @param filters edge filters
#'
#' @returns igraph with edge attribute .edgetype
#'
#' @export
#' @examples
#' classify_edges(example_network, filters = list(edge_type = "A"))
classify_edges <- function(g, filters = list()) {
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
  igraph::E(g)$.edgetype <- "bad"
  igraph::E(g)[keep]$.edgetype <- "good"
  g
}
#' remove bad edges
#'
#' @param g igraph object with edge variable .edgetype
#'
#' @returns igraph object
#'
#' @export
#' @examples
#' classify_edges(example_network, filters = list(edge_type = "A")) |>
#' remove_bad_edges()
remove_bad_edges <- function(g) {
  checkmate::assert_choice(".edgetype", igraph::edge_attr_names(g))

  bad_idx <- which(igraph::edge_attr(g, ".edgetype") == "bad")
  if (length(bad_idx) == 0) {
    rlang::inform("No bad edges")
    return(g)
  }

  ep <- igraph::ends(g, bad_idx, names = FALSE)
  n <- igraph::vcount(g)
  m <- nrow(ep)

  dc <- unique(rbind(
    cbind(seq_len(m), ep[, 1], 1),
    cbind(seq_len(m), ep[, 2], 1)
  ))

  obj <- rep(1, n)

  sol <- lpSolve::lp(
    direction = "min",
    objective.in = obj,
    const.dir = rep(">=", m),
    const.rhs = rep(1, m),
    dense.const = dc,
    all.bin = TRUE
  )

  if (sol$status != 0) {
    rlang::abort("ILP solver did not find an optimal solution")
  }

  cover <- which(sol$solution > 0.5)
  g <- igraph::delete_vertices(g, cover)
  g
}

#' classify nodes
#'
#' @param g igraph object
#' @param filters node filters
#'
#' @returns igraph object with node var nodetype
#'
#' @export
#' @examples
#' classify_nodes(example_network, filters = list(site = "A"))
classify_nodes <- function(g, filters = list()) {
  checkmate::assert_list(
    filters,
    names = "unique",
    min.len = 1
  )

  cols <- names(filters)
  checkmate::assertSubset(
    cols,
    igraph::vertex_attr_names(g)
  )

  keep <- rep(TRUE, igraph::vcount(g))

  for (col in cols) {
    values <- igraph::vertex_attr(g, col)
    keep <- keep & in_cutoff(values, filters[[col]])
  }
  igraph::V(g)$.nodetype <- "bad"
  igraph::V(g)[keep]$.nodetype <- "good"
  g
}
#' pruner
#'
#' @param g igraph object
#' @param edge_filters edges to keep. The edges that are removed
#' will remove vertices
#' @param node_filters nodes to keep
#'
#' @returns igraph object
#'
#' @export
#' @examples
#' pruner(example_network,
#' edge_filters = list(edge_type = c("A", "B")),
#' node_filters = list(site = "A")
#' )
pruner <- function(g, edge_filters = list(), node_filters = list()) {
  g
  if (length(node_filters) > 0) {
    g <- g |> classify_nodes(node_filters)
    g <- igraph::delete_vertices(g, which(igraph::V(g)$.nodetype == "bad"))
  }
  if (length(edge_filters) > 0) {
    g <- g |> classify_edges(edge_filters)
    g <- g |> remove_bad_edges()
  }
  # Recalc centrality and clustering
  g <- g |> add_centrality() |> add_clustering()
  g
}

if (sys.nframe() == 5) {
  pruner(example_network) |>
    plot_network(
      fill = "site",
      edge = "edge_type",
      label = ".degree"
    ) |>
    print()
  pruner(
    example_network,
    node_filters = list(site = c("A", "B")),
    edge_filters = list(edge_type = c("A", "B"))
  ) |>
    plot_network(
      fill = "site",
      edge = "edge_type",
      label = ".degree"
    ) |>
    print()
}
