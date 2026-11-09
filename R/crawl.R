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

if (sys.nframe() == 5) {
  example_network |> print()
  g <- label_crawl(example_network, nodes = c(1, 2))
  g |> print()
  plot_network(
    g,
    fill = "crawl",
    label = "name"
  ) |>
    print()
}
