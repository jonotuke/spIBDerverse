#' Filter network
#'
#' Includes or excludes nodes based on regular expression
#'
#' @param g ibd network
#' @param node_inc regular expression for inclusion
#' @param node_exc regular expression for exclusion
#' @param filter_column node attribute to filter network on
#' @param cutoff cutoffs for filter
#' @param is_less_than in numeric filter do you keep less than or greater than
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
  filter_column = "none",
  cutoff = NULL,
  is_less_than = TRUE
) {
  if (filter_column != "none" & is.null(cutoff)) {
    rlang::abort("You must give a cutoff is you filter on a node attribute")
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
  if (filter_column != "none") {
    node_values <- igraph::vertex_attr(g, filter_column)
    if (methods::is(node_values, "character")) {
      id <- igraph::V(g)[node_values %in% cutoff]
    } else {
      if (is_less_than) {
        id <- igraph::V(g)[node_values <= cutoff]
      } else {
        id <- igraph::V(g)[node_values >= cutoff]
      }
    }
  }
  igraph::induced_subgraph(g, id)
}
# filter_network(
#   example_network,
#   filter_column = "long",
#   cutoff = 138.6,
#   is_less_than = FALSE
# ) |>
#   print()
