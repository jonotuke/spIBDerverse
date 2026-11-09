label_crawl <- function(g, nodes, k = 2, mode = "all") {
  seeds <- as.numeric(igraph::V(g)[nodes])
  within <- igraph::ego(
    g,
    order = k,
    nodes = nodes,
    mode = mode
  ) |>
    purrr::map(as.numeric) |>
    purrr::list_c() |>
    unique()

  igraph::V(g)$crawl <- "outside"
  igraph::V(g)$crawl[within] <- "crawl"
  igraph::V(g)$crawl[seeds] <- "seed"
  g
}
names_to_ids <- function(g, node_names) {
  ids <- match(node_names, igraph::V(g)$name)
  missing <- node_names[is.na(ids)]
  if (length(missing) > 0) {
    rlang::abort(
      stringr::str_c(
        "Not found in graph: ",
        stringr::str_c(missing, collapse = ", ")
      )
    )
  }
  ids
}

if (sys.nframe() == 5) {
  example_network |> print()
  ids <- names_to_ids(example_network_2, c("RKF099", "RKC001"))
  g <- label_crawl(example_network_2, nodes = c("RKF099", "RKC001"))
  g |> print()
  plot_network(
    g,
    fill = "crawl"
  ) |>
    print()
}
