remove_bad_edges <- function(g) {
  bad_idx <- which(igraph::edge_attr(g, ".edgetype") == "bad")
  if (length(bad_idx) == 0) {
    rlang::inform("No bad edges")
    return(g)
  }

  # Endpoints of the bad edges as numeric vertex ids
  ep <- igraph::ends(g, bad_idx, names = FALSE)
  n <- igraph::vcount(g)
  m <- nrow(ep)

  # Sparse constraint matrix: one row per bad edge, entry 1 for each endpoint.
  # unique() handles self-loops, where the constraint becomes x_v >= 1.
  dc <- unique(rbind(
    cbind(seq_len(m), ep[, 1], 1),
    cbind(seq_len(m), ep[, 2], 1)
  ))

  # Objective: number of vertices removed, or total weight if weights are given
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
attr_in_cutoff <- function(values, cutoff) {
  if (is.numeric(values)) {
    cutoff <- suppressWarnings(
      as.numeric(cutoff)
    )
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
add_good_edges <- function(g, filters = list()) {
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
    keep <- keep & attr_in_cutoff(values, filters[[col]])
  }
  igraph::E(g)$.edgetype <- "bad"
  igraph::E(g)[keep]$.edgetype <- "good"
  g
}
add_good_nodes <- function(g, filters = list()) {
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
    keep <- keep & attr_in_cutoff(values, filters[[col]])
  }
  igraph::V(g)$.type <- "bad"
  igraph::V(g)[keep]$.type <- "good"
  g
}
pruner <- function(g, edge_filters = list(), node_filters = list()) {
  g
  if (length(node_filters) > 0) {
    g <- g |> add_good_nodes(node_filters)
    g <- igraph::delete_vertices(g, which(igraph::V(g)$.type == "bad"))
  }
  if (length(edge_filters) > 0) {
    g <- g |> add_good_edges(edge_filters)
    g <- g |> remove_bad_edges()
  }
  g
}

if (sys.nframe() == 5) {
  # ---- Example ----
  example_network |>
    pruner(
      node_filters = list(site = c("A", "B")),
      edge_filters = list(edge_type = c("A", "B"))
    ) |>
    plot_network(fill = "site", edge = "edge_type") |>
    print()
}
