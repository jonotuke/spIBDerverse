#' Filter network
#'
#' Includes or excludes nodes based on regular expression
#'
#' @param g ibd network
#' @param node_inc regular expression for inclusion
#' @param node_exc regular expression for exclusion
#'
#' @return filtered IBD network
#' @export
#'
#' @examples
#' filter_network(example_network, node_exc = "1")
filter_network <- function(
  g,
  node_inc = "",
  node_exc = ""
) {
  id <- igraph::V(g)$name
  if (node_inc != "") {
    id <- id |> purrr::keep(\(x) stringr::str_detect(x, node_inc))
  }
  if (node_exc != "") {
    id <- id |> purrr::keep(\(x) !stringr::str_detect(x, node_exc))
  }
  igraph::induced_subgraph(g, id)
}
# filter_network(example_network, node_exc = "1")
