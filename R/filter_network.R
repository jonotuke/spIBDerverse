#' Filter network
#'
#' Includes or excludes nodes based on regular expression
#'
#' @param g ibd network
#' @param node_inc regular expression for inclusion
#' @param node_exc regular expression for exclusion
#' @param node_column node attribute to filter network on
#' @param node_cutoff cutoffs for node filter
#' @param edge_column edge attributes to filter network on
#' @param edge_cutoff cutoffs for edge filter
#'
#' @return filtered IBD network
#' @export
#'
#' @examples
#' filter_network(example_network, node_exc = "1")
filter_network <- function(
  g,
  node_inc = "",
  node_exc = "",
  node_column = "none",
  node_cutoff = NULL,
  edge_column = "none",
  edge_cutoff = NULL
) {
  if (node_column != "none" & is.null(node_cutoff)) {
    rlang::abort(
      "You must give a node_cutoff if you filter on a node attribute"
    )
  }
  if (edge_column != "none" & is.null(edge_cutoff)) {
    rlang::abort(
      "You must give a edge_cutoff if you filter on a edge attribute"
    )
  }
  id <- igraph::V(g)$name
  if (node_inc != "") {
    node_inc <- convert_pipe(node_inc)
    id <- id |> purrr::keep(\(x) stringr::str_detect(x, node_inc))
  }
  if (node_exc != "") {
    node_exc <- convert_pipe(node_exc)
    id <- id |> purrr::keep(\(x) !stringr::str_detect(x, node_exc))
  }
  if (node_column != "none") {
    node_values <- igraph::vertex_attr(g, node_column)
    if (methods::is(node_values, "character")) {
      id <- igraph::V(g)[node_values %in% node_cutoff]
    } else {
      id <- igraph::V(g)[
        dplyr::between(node_values, node_cutoff[1], node_cutoff[2])
      ]
    }
    g <- igraph::induced_subgraph(g, id)
  }
  if (edge_column != "none") {
    edge_values <- igraph::edge_attr(g, edge_column)
    if (methods::is(edge_values, "character")) {
      id <- igraph::E(g)[edge_values %in% edge_cutoff]
    } else {
      id <- igraph::E(g)[
        dplyr::between(edge_values, edge_cutoff[1], edge_cutoff[2])
      ]
    }
    g <- igraph::subgraph_from_edges(g, id)
  }
  g <- g |> add_centrality_measures()
  g
}
# filter_network(
#   example_network,
#   edge_column = "edge_type",
#   edge_cutoff = c("A")
# ) |>
#   print()
