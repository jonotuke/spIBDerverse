#' label crawl
#'
#' Takes an igraph object and a list of nodes as integers and labels
#' the nodes as either seed, in neighbourhood or not
#'
#' @param g igraph object
#' @param nodes vector of nodes
#' @param k number of steps, default 2
#'
#' @returns igraph object with node attribute called .crawl
#'
#' @export
#' @examples
#' label_crawl(example_network, c(1, 2))
label_crawl <- function(g, nodes, k = 2L) {
  checkmate::assert_class(g, "igraph")
  checkmate::assert_numeric(nodes)
  checkmate::assert_integer(k)

  seeds <- as.numeric(igraph::V(g)[nodes])
  within <- igraph::ego(
    g,
    order = k,
    nodes = nodes,
    mode = "all"
  ) |>
    purrr::map(as.numeric) |>
    purrr::list_c() |>
    unique()

  igraph::V(g)$.crawl <- "outside"
  igraph::V(g)$.crawl[within] <- "crawl"
  igraph::V(g)$.crawl[seeds] <- "seed"
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
  g <- label_crawl(example_network, nodes = c(1, 2))
  g |> print()
  plot_network(
    g,
    fill = ".crawl"
  ) |>
    print()
}
