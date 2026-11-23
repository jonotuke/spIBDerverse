remove_bad_edges <- function(g) {
  bad_idx <- which(edge_attr(g, ".type") == "bad")
  if (length(bad_idx) == 0) {
    rlang::inform("No bad edges")
    return(g)
  }

  # Endpoints of the bad edges as numeric vertex ids
  ep <- ends(g, bad_idx, names = FALSE)
  n <- vcount(g)
  m <- nrow(ep)

  # Sparse constraint matrix: one row per bad edge, entry 1 for each endpoint.
  # unique() handles self-loops, where the constraint becomes x_v >= 1.
  dc <- unique(rbind(
    cbind(seq_len(m), ep[, 1], 1),
    cbind(seq_len(m), ep[, 2], 1)
  ))

  # Objective: number of vertices removed, or total weight if weights are given
  obj <- rep(1, n)

  sol <- lp(
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

if (sys.nframe() == 5) {
  library(igraph)
  library(lpSolve)
  # ---- Example ----
  set.seed(1)
  g <- sample_gnp(30, 0.15)
  E(g)$.type <- sample(
    c("good", "bad"),
    ecount(g),
    replace = TRUE,
    prob = c(0.7, 0.3)
  )

  remove_bad_edges_min_vc(g) |> print()
}
