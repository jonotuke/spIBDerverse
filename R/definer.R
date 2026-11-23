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
  keep <- vertex_attr(g, ".crawl") %in% c("seed", "crawl")
  g <- induced_subgraph(g, V(g)[keep])
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
    keep <- keep & attr_in_cutoff(values, filters[[col]])
  }
  keep
}

if (sys.nframe() == 5) {
  g <- loader(
    "inst/extdata/crawl-ibd/crawl-ibd.tsv",
    "inst/extdata/crawl-ibd/crawl-meta.tsv",
    crawl_length = 2
  )
  definer(
    g,
    edge_filters = list(
      sum_ibd_8 = c(NA, 1000),
      frac_gp1 = c(0.7, NA)
    )
  ) |>
    plot_network(
      edge = "frac_gp1",
      node_size = 3
    ) |>
    print()
}
