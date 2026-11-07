#' checks that vector of names are node attributes in a given
#' network
#'
#' @param g igraph object
#' @param preds vector of node attributes
#'
#' @returns error or NULL
#'
#' @export
#' @examples
#' check_node_attributes(example_network, c("lat", "site"))
check_node_attributes <- function(g, preds) {
  checkmate::assert_character(preds)
  missing <- setdiff(
    preds,
    igraph::vertex_attr_names(example_network)
  )
  if (length(missing) > 0) {
    rlang::abort(
      stringr::str_glue(
        "The following are not in the node attributes:{missing}"
      )
    )
  }
}

if (sys.nframe() == 5) {
  pacman::p_load(conflicted, tidyverse, targets)
  check_node_attributes(example_network, c("lat", "site")) |> print()
}
