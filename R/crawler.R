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
#' crawler(example_network, c(1, 2))
crawler <- function(g, nodes, k = 2L) {
  checkmate::assert_class(g, "igraph")
  checkmate::assert_numeric(nodes)

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

#' Find the vertex id from a name
#'
#' @param g igraph object
#' @param node_names vector of node names
#'
#' @returns vector of node ids
#'
#' @export
#' @examples
#' names_to_ids(example_network_2, "RKF040")
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
